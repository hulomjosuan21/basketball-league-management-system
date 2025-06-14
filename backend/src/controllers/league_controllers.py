from flask import request
from src.models.league_administrator_model import LeagueAdministratorModel
from src.models.league_model import LeagueModel, LeagueCategoryModel
from src.utils.api_response import ApiResponse
from src.extensions import db
from datetime import datetime
from sqlalchemy.orm import joinedload
from sqlalchemy import func
import difflib
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
            db.session.flush()  # This generates league.league_id

            # Add categories
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
