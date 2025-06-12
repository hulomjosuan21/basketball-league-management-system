from datetime import timedelta
from flask_jwt_extended import create_access_token
from src.services.email_services import send_verification_email
from src.errors.errors import AuthException
from src.utils.file_utils import save_file
from src.models.player_model import PlayerModel
from src.utils.api_response import ApiResponse
from src.extensions import db
from flask import request, jsonify, render_template_string
from src.models.user_model import AccountTypeEnum, UserModel

class TeamCreatorAuthController:
    async def create_creator(self):
        try:
            data = request.get_json()
            email = data.get('email')
            password_str = data.get('password_str')
            account_type = data.get('account_type')
            contact_number = data.get('contact_number')

            if not all([email, password_str, account_type, contact_number]):
                raise ValueError("All fields must be provided and not empty.")
            user = UserModel(
                email=email,
                contact_number=contact_number
            )
            user.set_account_type(account_type)
            user.set_password(password_str)

            db.session.add(user)
            db.session.commit()
            
            verify_link = f"/user/{user.user_id}"

            await send_verification_email(email, verify_link, request)
            
            return ApiResponse.success(message="Verification link sent to email.",status_code=201)
        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(e)