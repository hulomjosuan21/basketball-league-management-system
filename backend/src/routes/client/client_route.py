from src.controllers.auth.client_auth_controllers import ClientAuthControllers
from flask import Blueprint

client_bp = Blueprint('client', __name__, url_prefix='/client')

clientAuthControllers = ClientAuthControllers()

client_bp.post('/login-account')(clientAuthControllers.login_client)