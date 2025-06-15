from flask import Blueprint
from src.controllers.team_controllers import TeamControllers

team_bp = Blueprint('team', __name__, url_prefix='/team')

teamControllers = TeamControllers()
team_bp.get('/get/by/<string:team_id>')(teamControllers.get_team)
team_bp.post('/create-new')(teamControllers.create_team)
team_bp.put('/add-player')(teamControllers.add_player)
team_bp.put('/set-team-captain/<string:team_id>')(teamControllers.set_team_captain)

team_bp.delete('/remove-player/<string:player_team_id>')(teamControllers.remove_player)