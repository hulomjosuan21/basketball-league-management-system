from flask import Blueprint

from src.controllers.auth.player_auth_controllers import PlayerAuthControllers

player_bp = Blueprint('player', __name__, url_prefix='/player')

playerAuthControllers = PlayerAuthControllers()

player_bp.post('/register-account')(playerAuthControllers.create_player)