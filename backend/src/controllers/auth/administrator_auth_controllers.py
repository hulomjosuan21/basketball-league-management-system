from flask import make_response, request, jsonify, render_template_string
from src.errors.errors import AuthException
from src.extensions import db
from src.models.league_administrator_model import LeagueAdministratorModel
from src.models.user_model import UserModel
from src.services.email_services import send_verification_email
from src.utils.api_response import ApiResponse
from werkzeug.exceptions import NotFound, Forbidden

from src.utils.html_template import email_html_template

class AdministratorAuthControllers:
    async def create_administrator(self):
        try:
            data = request.get_json()
            
            user_data = data.get('user')
            email = user_data.get('email')
            password_str = user_data.get('password_str')
            account_type = user_data.get('account_type')

            organization_type = data.get('organization_type')
            organization_name = data.get('organization_name')
            contact_number = data.get('contact_number')
            barangay_name = data.get('barangay_name')
            municipality_name = data.get('municipality_name')

            if not all([email, password_str, account_type, organization_name, contact_number, barangay_name, municipality_name]):
                raise ValueError("All fields must be provided and not empty.")
            
            user = UserModel(email=email)
            user.set_account_type(account_type)
            user.set_password(password_str)

            league_administrator = LeagueAdministratorModel(
                user=user,
                organization_type=organization_type,
                organization_name=organization_name,
                contact_number=contact_number,
                barangay_name=barangay_name,
                municipality_name=municipality_name
            )
            
            db.session.add(user)
            db.session.add(league_administrator)
            db.session.commit()

            verify_link = f"/administrator/{user.user_id}"

            await send_verification_email(email, verify_link, request)

            return ApiResponse.success(message="Verification link sent to email.",status_code=201)
        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(e)
        
    def verify_administrator_account(self, user_id):
        try:
            if not user_id:
                raise ValueError("Missing user credentials")

            user = UserModel.query.filter_by(user_id=user_id).first()

            if not user:
                return make_response(
                    email_html_template("Verification Failed", "User not found.",'error'), 404
                )

            if user.is_verified:
                return make_response(
                    email_html_template("Already Verified", "Your account is already verified.",'info'), 200
                )

            user.is_verified = True
            db.session.commit()

            return make_response(
                email_html_template("Account Verified", "Your account has been verified successfully!"), 200
            )

        except Exception as e:
            return make_response(
                email_html_template("Error Occurred","✕ Something went wrong!",'error'),500
            )
        
    async def login_administrator(self):
        try:
            data = request.get_json()
            email = data.get('email')
            password_str = data.get('password_str')

            if not email or not password_str:
                raise ValueError("Missing required fields: email, password")

            user = UserModel.query.filter(UserModel.email == email).first()

            league_administrator = user.league_administrator;

            if not user.is_verified:
                raise AuthException("Your account is not verified.",403)

            user.verify_password(password_str)

            payload = league_administrator.to_json()

            return ApiResponse.success(message="Login successful.",payload=payload)
        except Exception as e:
            return ApiResponse.error(e)