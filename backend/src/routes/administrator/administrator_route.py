from flask import Blueprint

administrator_bp = Blueprint('administrator', __name__, url_prefix='/administrator')

from src.controllers.auth.administrator_auth_controllers import AdministratorAuthControllers

administratorAuthControllers = AdministratorAuthControllers()

administrator_bp.post('/register-account')(administratorAuthControllers.create_administrator)
administrator_bp.get('/<string:user_id>')(lambda user_id: administratorAuthControllers.verify_administrator_account(user_id))
administrator_bp.post('/login-account')(administratorAuthControllers.login_administrator)