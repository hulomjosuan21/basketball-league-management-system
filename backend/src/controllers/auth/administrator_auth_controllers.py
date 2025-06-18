from flask import make_response, request, jsonify, render_template_string
from src.utils.file_utils import save_file
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
            email = request.form.get('user[email]')
            password_str = request.form.get('user[password_str]')
            account_type = request.form.get('user[account_type]')
            contact_number = request.form.get('user[contact_number]')

            organization_type = request.form.get('organization_type')
            organization_name = request.form.get('organization_name')
            organization_address = request.form.get('organization_address')

            organization_logo_file = request.files.get('organization_logo_file')

            if not all([email, password_str, account_type, organization_name, contact_number, organization_address]):
                raise ValueError("All fields must be provided and not empty.")
            
            user = UserModel(
                email=email,
                contact_number=contact_number,
                account_type=account_type
            )
            user.set_password(password_str)

            league_administrator = LeagueAdministratorModel(
                user=user,
                organization_type=organization_type,
                organization_name=organization_name,
                organization_address=organization_address,
            )
            
            full_url = await save_file(organization_logo_file, 'images', request, 'supabase')
            league_administrator.organization_logo_url = full_url

            db.session.add(user)
            db.session.add(league_administrator)
            db.session.commit()

            verify_link = f"/user/{user.user_id}"

            await send_verification_email(email, verify_link, request)

            return ApiResponse.success(redirect="/administrator/login", message="Verification link sent to email.",status_code=201)
        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(e)
        
    def fetch_administrator(self, user_id):
        try:
            user = UserModel.query.get(user_id)
            if not user:
                raise AuthException("No User found.", 401)
            
            league_administrator = user.league_administrator

            payload = league_administrator.to_json();
            return ApiResponse.success(payload=payload)
        except Exception as e:
            return ApiResponse.error(e)
        
    def login_administrator(self):
        try:
            data = request.get_json()
            email = data.get('email')
            password_str = data.get('password_str')

            if not email or not password_str:
                raise ValueError("Missing required fields: email, password")

            user = UserModel.query.filter(UserModel.email == email).first()

            if not user or not user.verify_password(password_str):
                raise AuthException("Invalid email or password.", 401)

            if not user.is_verified:
                raise AuthException("Your account is not verified.", 403)
            
            additional_claims = {
                "account_type": str(user.account_type)
            }
 
            access_token = create_access_token(
                identity=user.user_id,
                additional_claims=additional_claims,
                expires_delta=timedelta(weeks=1)
            )

            payload = {
                'access_token': access_token
            }

            return ApiResponse.success(redirect="/administrator/main/screen",message="Login successful.",payload=payload)
            # return ApiResponse.success()
        except Exception as e:
            return ApiResponse.error(e)