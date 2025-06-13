from src.utils.db_utils import CreatedAt, UUIDGenerator, UpdatedAt
from src.extensions import db
from datetime import datetime

class LeagueModel(db.Model):
    __tablename__ = 'leagues_table'

    league_id = UUIDGenerator(db, 'league')
    league_administrator_id = db.Column(db.String, db.ForeignKey('league_administrator_table.league_administrator_id'))

    league_title = db.Column(db.String(100), nullable=False)
    league_budget = db.Column(db.Float, nullable=True, default=0.0)

    registration_deadline = db.Column(db.DateTime, nullable=False)
    opening_date = db.Column(db.DateTime, nullable=False)
    start_date = db.Column(db.DateTime, nullable=False)

    championship_trophy_url = db.Column(db.String, nullable=True)
    banner_url = db.Column(db.String, nullable=True)

    status = db.Column(db.String(100), nullable=False, default="Scheduled") # Scheduled, Ongoing, Completed, Postponed, Cancelled

    season_year = db.Column(db.Integer, nullable=False, default=datetime.now().year)
    rules = db.Column(db.Text, nullable=False)
    
    league_format = db.Column(db.Text, nullable=False)
    sponsors = db.Column(db.Text, nullable=True)

    # many to one
    league_administrator = db.relationship(
        'LeagueAdministratorModel',
        back_populates='created_leagues',
        cascade='all, delete-orphan',
        single_parent=True
    )

    def to_json(self) -> dict:
        return {
            "league_id": self.league_id,
            "league_administrator_id": self.league_administrator_id,
            "league_title": self.league_title,
            "league_budget": float(self.league_budget),
            "league_picture_url": self.league_picture_url,
            "league_budget": self.league_budget,
            "registration_deadline": self.registration_deadline.isoformat() if self.registration_deadline else None,
            "opening_date": self.opening_date.isoformat() if self.opening_date else None,
            "start_date": self.start_date.isoformat() if self.start_date else None,
            "championship_trophy_url": self.championship_trophy_url if self.championship_trophy_url else None,
            "banner_url": self.banner_url if self.banner_url else None,
            "season_year": self.season_year,
            "categories": [assoc.category.to_json() for assoc in self.categories] if self.leagcategoriesue_teams else [],
            "rules": self.rules,
            "league_format": self.league_format,
            "sponsors": self.sponsors,
            "league_administrator": self.league_administrator.to_json() if self.league_administrator else None,
            "league_teams": [assoc.team.to_json() for assoc in self.league_teams] if self.league_teams else [],
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }

    categories = db.relationship(
        'LeagueCategoryModel',
        back_populates='league',
        cascade='all, delete-orphan'
    )

    league_teams = db.relationship(
        'LeagueTeamModel',
        back_populates='league',
        cascade='all, delete-orphan'
    )

    # use for founded_at
    created_at = CreatedAt(db)
    updated_at = UpdatedAt(db)

    
class LeagueTeamModel(db.Model):
    __tablename__ = 'league_teams_table'

    league_team_id = UUIDGenerator(db, 'league-team')
    team_id = db.Column(db.String, db.ForeignKey('teams_table.team_id'))
    league_id = db.Column(db.String, db.ForeignKey('leagues_table.league_id'))
    category_id = db.Column(db.String, db.ForeignKey('league_categories_table.category_id'))

    wins = db.Column(db.Integer, default=0, nullable=False)
    losses = db.Column(db.Integer, default=0, nullable=False)
    draws = db.Column(db.Integer, default=0, nullable=False)
    points = db.Column(db.Integer, default=0, nullable=False)

    __table_args__ = (
        db.CheckConstraint('wins >= 0', name='check_wins_positive'),
        db.CheckConstraint('losses >= 0', name='check_losses_positive'),
        db.CheckConstraint('draws >= 0', name='check_draws_positive'),
        db.CheckConstraint('points >= 0', name='check_points_positive'),
    )

    team = db.relationship(
        'TeamModel',
        back_populates='league_registrations'
    )
    league = db.relationship('LeagueModel', back_populates='league_teams')
    category = db.relationship('LeagueCategoryModel', back_populates='category_teams')

    created_at = CreatedAt(db)
    updated_at = UpdatedAt(db)

    def to_json(self) -> dict:
        return {
            "league_team_id": self.league_team_id,
            "team_id": self.team_id,
            "league_id": self.league_id,
            "category_id": self.category_id,
            "team": self.team.to_json() if self.team else None,
            "league": self.league.to_json() if self.league else None,
            "category": self.category.to_json() if self.category else None,
            "wins": self.wins,
            "losses": self.losses,
            "draws": self.draws,
            "points": self.points,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }


class LeagueCategoryModel(db.Model):
    __tablename__ = 'league_categories_table'

    category_id = UUIDGenerator(db, 'category')
    league_id = db.Column(db.String, db.ForeignKey('leagues_table.league_id'))

    category_name = db.Column(db.String(100), nullable=False)

    category_teams = db.relationship('LeagueTeamModel', back_populates='category')

    stage = db.Column(db.String(100), nullable=False, default="Group Stage")
    max_team = db.Column(db.Integer, nullable=False, default=4)

    created_at = CreatedAt(db)
    updated_at = UpdatedAt(db)

    league = db.relationship('LeagueModel', back_populates='categories')

    def to_json(self) -> dict:
        return {
            "category_id": self.category_id,
            "league_id": self.league_id,
            "category_name": self.category_name,
            "category_teams": [assoc.team.to_json() for assoc in self.category_teams] if self.category_teams else [],
            "max_team": self.max_team,
            "stage": self.stage,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }