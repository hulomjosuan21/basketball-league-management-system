from src.utils.db_utils import CreatedAt, UUIDGenerator, UpdatedAt
from src.extensions import db

class LeagueModel(db.Model):
    __tablename__ = 'leagues_table'

    league_id = UUIDGenerator(db, 'team')
    league_administrator_id = db.Column(db.String, db.ForeignKey('league_administrator_table.league_administrator_id'))

    league_name = db.Column(db.String(100), nullable=False)
    league_description = db.Column(db.Text, nullable=False)
    league_picture_url = db.Column(db.String, nullable=False)
    league_budget = db.Column(db.Float, nullable=False, default=0.0)

    registration_deadline = db.Column(db.DateTime, nullable=False)

    championship_trophy_url = db.Column(db.String, nullable=True)

    # many to one
    league_administrator = db.relationship(
        'LeagueAdministratorModel',
        back_populates='created_leagues',
        cascade='all, delete-orphan'
    )

    # use for founded_at
    created_at = CreatedAt(db)
    updated_at = UpdatedAt(db)

    def to_json(self):
        return {
            "league_id": self.league_id,
            "league_administrator_id": self.league_administrator_id,
            "league_name": self.league_name,
            "league_description": self.league_description,
            "league_picture_url": self.league_picture_url,
            "league_budget": self.league_budget,
            "registration_deadline": self.registration_deadline,
            "championship_trophy_url": self.championship_trophy_url,
        }