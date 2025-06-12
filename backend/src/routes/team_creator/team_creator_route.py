from flask import Blueprint

from src.controllers.auth.teamcreator_auth_controllers import TeamCreatorAuthController

team_creator_bp = Blueprint('team-creator', __name__, url_prefix='/team-creator')

teamCreatorAuthController = TeamCreatorAuthController()

team_creator_bp.post('/register-account')(teamCreatorAuthController.create_creator)