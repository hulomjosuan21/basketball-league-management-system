from flask import Blueprint

from src.controllers.league_controllers import LeagueControllers

league_bp = Blueprint('league', __name__,url_prefix='/league')


leagueControllers = LeagueControllers()

league_bp.post('/create-new')(leagueControllers.create_league)
league_bp.put('/upload/banner/trophy/<string:league_id>')(lambda league_id: leagueControllers.upload_league_images(league_id))