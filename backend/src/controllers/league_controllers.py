from flask import request
from src.models.league_model import LeagueModel, LeagueCategoryModel
from src.utils.api_response import ApiResponse
from src.extensions import db
from datetime import datetime

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

    # async def create_league(self):
    #     try:
    #         data = request.get_json()
    #         league_administrator_id = data.get('league_administrator_id')
    #         league_title = data.get('league_title')
    #         league_description = data.get('league_description')
    #         league_budget = data.get('league_budget')
    #         registration_deadline = data.get('registration_deadline')
    #         opening_date = data.get('opening_date')
    #         start_date = data.get('start_date')
    #         league_rules = data.get('league_rules')
    #         status = data.get('status')
    #         categories = data.get('categories')
    #         sponsors = data.get('sponsors')

    #         print(league_administrator_id)
    #         print(league_title)
    #         print(league_description)
    #         print(league_budget)
    #         print(registration_deadline)
    #         print(opening_date)
    #         print(start_date)
    #         print(league_rules)
    #         print(status)
    #         print(categories)

    #         categoriesModel = []
    #         this is the LeagueCategoryModel 


    #         league = LeagueModel(
    #             league_administrator_id=league_administrator_id,
    #             league_title=league_title,
    #             league_description=league_description,
    #             league_budget=league_budget,
    #             registration_deadline=datetime.fromisoformat(registration_deadline),
    #             opening_date=datetime.fromisoformat(opening_date),
    #             start_date=datetime.fromisoformat(start_date),
    #             league_rules=league_rules,
    #             status=status,
    #             sponsors=sponsors if sponsors else None,
    #             categories= 
    #         );

    #         return ApiResponse.success()
    #     except Exception as e:
    #         db.session.rollback()
    #         return ApiResponse.error(e)