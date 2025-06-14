from flask import request
from src.models.league_model import LeagueModel, LeagueCategoryModel
from src.utils.api_response import ApiResponse
from src.extensions import db
from datetime import datetime

from src.utils.file_utils import save_file

class LeagueControllers:
    async def create_league(self):
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
        
    async def upload_league_images(self, league_id: str):
        try:
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