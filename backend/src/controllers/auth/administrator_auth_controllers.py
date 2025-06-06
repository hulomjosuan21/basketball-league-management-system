from flask import make_response, request, jsonify, render_template_string
from src.errors.errors import AuthException
from src.extensions import db
from src.models.league_administrator_model import LeagueAdministratorModel
from src.models.user_model import UserModel
from src.services.email_services import send_verification_email
from src.utils.api_response import ApiResponse
from flask_jwt_extended import (
    create_access_token,
    set_access_cookies,
)
from datetime import timedelta

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

            verify_link = f"/user/{user.user_id}"

            await send_verification_email(email, verify_link, request)

            return ApiResponse.success(message="Verification link sent to email.",status_code=201)
        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(e)
        
    async def fetch_administrator(self, user_id):
        try:
            user = UserModel.query.filter(UserModel.user_id == user_id).first()
            if not user:
                raise AuthException("No User found.", 401)
            
            league_administrator = user.league_administrator

            print(league_administrator)
            return ApiResponse.success()
        except Exception as e:
            return ApiResponse.error(e)
        
    async def login_administrator(self):
        try:
            data = request.get_json()
            email = data.get('email')
            password_str = data.get('password_str')

            if not email or not password_str:
                raise ValueError("Missing required fields: email, password")

            user = UserModel.query.filter(UserModel.email == email).first()

            if not user:
                raise AuthException("Invalid email or password.", 401)

            if not user.is_verified:
                raise AuthException("Your account is not verified.", 403)

            if not user.verify_password(password_str):
                raise AuthException("Invalid email or password.", 401)

            user.verify_password(password_str)

            access_token = create_access_token(identity=user.user_id,expires_delta=timedelta(weeks=1))

            payload = {
                'access_token': access_token
            }

            return ApiResponse.success(message="Login successful.",payload=payload)
        except Exception as e:
            return ApiResponse.error(e)