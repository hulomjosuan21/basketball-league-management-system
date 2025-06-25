from src.models.user_model import UserModel
from src.models.player_model import PlayerModel
from src.extensions import db
from src.utils.api_response import ApiResponse
from flask import request
from src.models.team_model import TeamModel, PlayerTeamModel
from src.utils.file_utils import save_file
from sqlalchemy import or_
import difflib

class TeamControllers:
    def get_team_by_team_id(self, team_id):
        try:
            team = TeamModel.query.filter(TeamModel.team_id == team_id).first()
            payload = team.to_json()
            return ApiResponse.success(payload=payload)
        except Exception as e:
            return ApiResponse.error(str(e))
        
    def get_teams_by_user_id(self, user_id: str):
        try:
            teams = TeamModel.query.filter(TeamModel.user_id == user_id).all()
            if not teams:
                return ApiResponse.success(message="No teams found.", payload=[])
            
            payload = [team.to_json() for team in teams]
            return ApiResponse.success(payload=payload)
        except Exception as e:
            return ApiResponse.error(f"Error fetching teams for user {user_id}: {str(e)}")

        
    async def create_team(self):
        try:
            user_id = request.form.get('user_id')
            team_name = request.form.get('team_name')
            team_address = request.form.get('team_address')
            contact_number = request.form.get('contact_number')
            team_motto = request.form.get('team_motto')
            coach_name = request.form.get('coach_name')
            assistant_coach_name = request.form.get('assistant_coach_name')
            
            if not all([user_id, team_name, team_address, contact_number, coach_name]):
                raise ValueError("All fields must be provided and not empty.")

            team = TeamModel(
                user_id=user_id,
                team_name=team_name,
                team_address=team_address,
                contact_number=contact_number,
                team_motto=team_motto,
                coach_name=coach_name,
                assistant_coach_name=assistant_coach_name
            )

            team_logo_image = request.files.get('team_logo_image')
            if team_logo_image:
                team_logo_url = await save_file(team_logo_image, 'team-logos', request, 'supabase')
                team.team_logo_url = team_logo_url

            db.session.add(team)
            db.session.commit()
            payload = team.to_json()
            return ApiResponse.success(message=f"New Team Created: {team_name}",payload=payload)
        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(str(e))
        
    def set_team_captain(self, player_team_id):
        try:
            data = request.get_json()
            team_captain_id = data.get('team_captain_id')

            if not all([player_team_id, team_captain_id]):
                raise ValueError("All fields must be provided and not empty.")

            team = TeamModel.query.get(player_team_id)
            team.team_captain_id = team_captain_id

            db.session.commit()
            return ApiResponse.success(message=f"{team_captain_id} Set as Team Captain")
        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(str(e))

    def add_player_to_team_with_is_accepted(self):
        try:
            data = request.get_json()
            team_id = data.get('team_id')
            player_id = data.get('player_id')
            is_accepted = data.get('is_accepted')
            if not all([team_id, player_id]):
                raise ValueError("All fields must be provided and not empty.")

            playerTeam = PlayerTeamModel(
                team_id=team_id,
                player_id=player_id
            )
        
            db.session.add(playerTeam)
            db.session.flush()
            db.session.commit()

            last_name = playerTeam.player.last_name

            return ApiResponse.success(message=f"{last_name} Player Added")
        
        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(str(e))
        
    def invite_player(self):
        try:
            data = request.get_json()
            team_id = data.get('team_id')
            search = data.get('name_or_email', None)

            if not team_id:
                raise ValueError("Team ID is required.")
            if not search:
                raise ValueError("Search (name or email) is required.")

            player = None

            player = db.session.query(PlayerModel).join(PlayerModel.user).filter(UserModel.email == search).first()
            if not player:
                players = PlayerModel.query.all()
                name_to_player = {
                    p.full_name.strip(): p for p in players if p.full_name
                }

                best_matches = difflib.get_close_matches(
                    search.lower(),
                    [name.lower() for name in name_to_player.keys()],
                    n=1,
                    cutoff=0.5
                )

                if best_matches:
                    match = best_matches[0]
                    for full_name, p in name_to_player.items():
                        if full_name.lower() == match:
                            player = p
                            break

            if not player:
                raise ValueError("Player not found by name or email.")
            
            existing = PlayerTeamModel.query.filter_by(
                player_id=player.player_id,
                team_id=team_id
            ).first()

            if existing:
                return ApiResponse.error(f"{search} is already invited or in the team.",status_code=409)
            
            player_team = PlayerTeamModel(
                player_id=player.player_id,
                team_id=team_id,
                is_accepted='Invited'
            )

            db.session.add(player_team)
            db.session.commit()

            return ApiResponse.success(message=f"{player.full_name} invited to team.")

        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(str(e))

             
    def add_player(self):
        try:
            data = request.get_json()

            team_id = data.get('team_id')
            player_id = data.get('player_id')

            if not all([team_id, player_id]):
                raise ValueError("All fields must be provided and not empty.")

            playerTeam = PlayerTeamModel(
                team_id=team_id,
                player_id=player_id
            )
        
            db.session.add(playerTeam)

            db.session.flush()

            db.session.commit()

            last_name = playerTeam.player.last_name

            return ApiResponse.success(message=f"{last_name} Player Added")
        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(str(e))
        
    def remove_player(self, player_team_id):
        try:
            if not player_team_id:
                raise ValueError("All fields must be provided and not empty.")

            playerTeam = PlayerTeamModel.query.get(player_team_id)

            if not playerTeam:
                raise ValueError("Player not found.")

            team = playerTeam.team

            if team.team_captain_id == player_team_id:
                team.team_captain_id = None

            db.session.delete(playerTeam)
            db.session.commit()

            return ApiResponse.success(message="Player removed")
        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(str(e))
