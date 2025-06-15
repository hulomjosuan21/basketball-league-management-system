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

class ClientAuthControllers:    
    def login_client(self):
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
                "account_type": user.account_type.value
            }
 
            access_token = create_access_token(
                identity=user.user_id,
                additional_claims=additional_claims,
                expires_delta=timedelta(weeks=1)
            )

            payload = {
                'access_token': access_token
            }

            return ApiResponse.success(message="Login successful.",payload=payload)
        except Exception as e:
            return ApiResponse.error(e)