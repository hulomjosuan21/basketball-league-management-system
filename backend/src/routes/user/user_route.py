from flask import Blueprint

from src.controllers.user_controller import UserControllers

user_bp = Blueprint('user', __name__, url_prefix='/user')
userControllers = UserControllers()
user_bp.get('/<string:user_id>')(lambda user_id: userControllers.verify_administrator_account(user_id))
