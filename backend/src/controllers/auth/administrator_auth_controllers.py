from flask import request, json
from src.extensions import db
from src.models.user_model import UserModel
from src.utils.api_response import ApiResponse

class AdministratorAuthControllers:
    async def create_administrator(self):
        try:
            data = request.get_json()
            
            email = data.get('email')
            password_str = data.get('password_str')
            account_type = data.get('account_type')

            if not email or not password_str or not account_type:
                raise ValueError("Missing required fields: email, password_str, or account_type")
            
            print(email)
            print(password_str)
            print(account_type)

            newAdministrator = UserModel(email=email)
            newAdministrator.set_account_type(account_type)
            newAdministrator.set_password(password_str)
            
            db.session.add(newAdministrator)
            db.session.commit()

            return ApiResponse.success(status_code=201)
        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(e)