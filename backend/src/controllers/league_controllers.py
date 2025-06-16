from flask import request
from src.models.audit_log_model import AuditLogModel
from src.models.league_administrator_model import LeagueAdministratorModel
from src.models.league_model import LeagueModel, LeagueCategoryModel, LeaguePlayerModel, LeagueTeamModel
from src.models.team_model import PlayerTeamModel, TeamModel
from src.utils.api_response import ApiResponse
from src.extensions import db
from datetime import datetime
from sqlalchemy.orm import joinedload
from sqlalchemy import func
import difflib
from src.utils.db_utils import AccountTypeEnum
from src.utils.file_utils import save_file

class LeagueControllers:
    def filter_leagues_by_organization_details(self):
        try:
            data = request.get_json()

            organization_name = data.get('organization_name', '').lower()
            barangay_name = data.get('barangay_name', '').lower()
            municipality_name = data.get('municipality_name', '').lower()
            organization_type = data.get('organization_type', '').lower()

            leagues = db.session.query(LeagueModel).join(LeagueAdministratorModel).options(
                joinedload(LeagueModel.league_administrator)
            ).all()

            filtered = []
            for league in leagues:
                admin = league.league_administrator
                if not admin:
                    continue

                name_match = True
                if organization_name:
                    name_match = difflib.SequenceMatcher(
                        None, admin.organization_name.lower(), organization_name
                    ).ratio() >= 0.7

                barangay_match = True
                if barangay_name:
                    barangay_match = admin.barangay_name.lower() == barangay_name

                municipality_match = True
                if municipality_name:
                    municipality_match = admin.municipality_name.lower() == municipality_name

                type_match = True
                if organization_type:
                    type_match = admin.organization_type.lower() == organization_type

                if name_match and barangay_match and municipality_match and type_match:
                    filtered.append(league)

            payload = [league.to_json() for league in filtered]
            return ApiResponse.success(payload=payload)

        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(str(e))

    def create_league(self):
        try:
            data = request.get_json()
            league_administrator_id = data.get('league_administrator_id')
            league_title = data.get('league_title')
            league_description = data.get('league_description')
            league_budget = data.get('league_budget')
            registration_deadline = data.get('registration_deadline')
            opening_date = data.get('opening_date')
            start_date = data.get('start_date')
            league_rules = data.get('league_rules')
            status = data.get('status')
            categories = data.get('categories')
            sponsors = data.get('sponsors')

            if not all([league_administrator_id, league_title, league_description, league_budget, registration_deadline, opening_date, start_date, league_rules, status, categories]):
                raise ValueError("All fields must be provided and not empty.")

            # Create League instance
            league = LeagueModel(
                league_administrator_id=league_administrator_id,
                league_title=league_title,
                league_description=league_description,
                league_budget=league_budget,
                registration_deadline=datetime.fromisoformat(registration_deadline),
                opening_date=datetime.fromisoformat(opening_date),
                start_date=datetime.fromisoformat(start_date),
                league_rules=league_rules,
                status=status,
                sponsors=sponsors if sponsors else None
            )

            db.session.add(league)
            db.session.flush()

            for cat in categories:
                category = LeagueCategoryModel(
                    league_id=league.league_id,
                    category_name=cat.get('category_name'),
                    category_format=cat.get('category_format'),
                    max_team=cat.get('max_team', 4)
                )
                db.session.add(category)

            db.session.commit()
            return ApiResponse.success(message=f"New League Created {league_title}")

        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(e)
        
    async def upload_league_images(self):
        try:
            league_id = request.form.get('league_id')
            league = LeagueModel.query.get(league_id)

            if not league:
                raise ValueError("League not found")

            banner_image = request.files.get('banner_image')
            if banner_image:
                banner_url = await save_file(banner_image, 'banners', request, 'supabase')
                league.banner_url = banner_url

            championship_trophy_image = request.files.get('championship_trophy_image')
            if championship_trophy_image:
                trophy_url = await save_file(championship_trophy_image, 'trophies', request, 'supabase')
                league.championship_trophy_url = trophy_url

            db.session.commit()
            return ApiResponse.success()

        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(str(e))
        
    def update_league(self, league_id):
        try:
            data = request.get_json()

            league = LeagueModel.query.get(league_id)
            if not league:
                return ApiResponse.error("League not found")

            if 'registration_deadline' in data:
                data['registration_deadline'] = datetime.fromisoformat(data['registration_deadline'])
            if 'opening_date' in data:
                data['opening_date'] = datetime.fromisoformat(data['opening_date'])
            if 'start_date' in data:
                data['start_date'] = datetime.fromisoformat(data['start_date'])

            league.copy_with(**{
                'league_title': data.get('league_title'),
                'league_description': data.get('league_description'),
                'league_budget': data.get('league_budget'),
                'league_rules': data.get('league_rules'),
                'status': data.get('status'),
                'sponsors': data.get('sponsors'),
                'registration_deadline': data.get('registration_deadline'),
                'opening_date': data.get('opening_date'),
                'start_date': data.get('start_date'),
            })

            db.session.commit()
            return ApiResponse.success("League updated successfully")
        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(str(e))
    
    def delete_league(self, league_id):
        try:
            league = LeagueModel.query.get(league_id)
            if not league:
                return ApiResponse.error("League not found")

            db.session.delete(league)
            db.session.commit()
            return ApiResponse.success(message="League deleted successfully")

        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(str(e))

    def add_player_to_league(self, player_team_id) -> LeaguePlayerModel:
        player_team = PlayerTeamModel.query.get(player_team_id)
        if not player_team:
            raise ValueError("PlayerTeam not found.")

        player_id = player_team.player_id

        existing = (
            db.session.query(LeaguePlayerModel)
            .join(PlayerTeamModel, LeaguePlayerModel.player_team_id == PlayerTeamModel.player_team_id)
            .filter(
                LeaguePlayerModel.league_id == self.league_id,
                PlayerTeamModel.player_id == player_id
            )
            .first()
        )

        if existing:
            raise ValueError("This player is already registered in this league through another team.")

        league_player = LeaguePlayerModel(
            player_team_id=player_team_id,
            league_id=self.league_id,
            league_team_id=self.league_team_id
        )
        return league_player


    async def check_players_is_allowed_or_not(self, team_id) -> list[LeaguePlayerModel]:
        try:
            team = TeamModel.query.get(team_id)

            league_players = []
            for player in team.players:
                player_team_id = player.player_team_id
                if player.is_ban or player.player.is_ban or not player.player.is_allowed:
                    raise ValueError(f"Player {player_team_id} is Banned or not Allowed to play in every league")
                else:
                    league_player = self.add_player_to_league(player_team_id)
                    league_players.append(league_player)
                    AuditLogModel.log_action(
                        audit_by_id=self.league_administrator_id,
                        audit_by_type=AccountTypeEnum.LOCAL_ADMINISTRATOR.value,
                        audit_to_id=player.player.player_id,
                        audit_to_type=AccountTypeEnum.PLAYER.value,
                        action="Accepted",
                        details=f"Accepted to participate to League {self.league_title}"
                    )

            return league_players
        except Exception as e:
            raise

    async def accept_team(self):
        try:
            data = request.get_json()

            league_id = data.get('league_id')
            self.league_id = league_id

            team_id = data.get('team_id')
            category_id = data.get('category_id')

            league = LeagueModel.query.get(league_id)
            self.league_administrator_id = league.league_administrator_id
            self.league_title = league.league_title

            existing_league_team = LeagueTeamModel.query.filter_by(
                league_id=league_id,
                team_id=team_id
            ).first()

            if existing_league_team:
                raise ValueError("This team is already registered in the league.")

            league_team = LeagueTeamModel(
                league_id=league_id,
                team_id=team_id,
                category_id=category_id
            )

            db.session.add(league_team)
            db.session.flush()

            self.league_team_id = league_team.league_team_id

            league_players = await self.check_players_is_allowed_or_not(team_id)
            db.session.add_all(league_players)
            db.session.commit()
            return ApiResponse.success(message="Wait for the administrator to accept your team")
        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(str(e))
        
    def get_league_team(self, league_team_id):
        try:
            league_team = LeagueTeamModel.query.get(league_team_id)
            if not league_team:
                raise ValueError("No Team Found!")
            
            payload = league_team.team_to_json()
            return ApiResponse.success(payload=payload)
        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(str(e))
        
    def set_league_team_status(self, league_team_id):
        try:
            data = request.get_json()
            status = data.get('status')
            if not status:
                raise ValueError("All fields must be provided and not empty.")

            league_team = LeagueTeamModel.query.get(league_team_id)

            if not league_team:
                raise ValueError("Team not found")
            
            league_team.status = status

            db.session.commit()

            details = f"Your Team {league_team.team.team_name} has been {status}"

            AuditLogModel.log_action(
                audit_by_id=league_team.league.league_administrator_id,
                audit_by_type=AccountTypeEnum.LOCAL_ADMINISTRATOR.value,
                audit_to_id=league_team.team.user_id,
                audit_to_type=AccountTypeEnum.TEAM_CREATOR.value,
                action=status,
                details=details
            )

            return ApiResponse.success(payload=details)
        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(str(e))