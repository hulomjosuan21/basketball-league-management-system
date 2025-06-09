from src.utils.db_utils import CreatedAt, UUIDGenerator, UpdatedAt
from src.extensions import db

class TeamModel(db.Model):
    __tablename__ = 'teams_table'

    team_id = UUIDGenerator(db, 'team')
    user_id = db.Column(db.String, db.ForeignKey('users_table.user_id'))

    team_name = db.Column(db.String(100), nullable=False)
    team_address = db.Column(db.String(100), nullable=False)
    championships_won = db.Column(db.Integer, default=0)
    coach_name = db.Column(db.String(100))

    # many to one
    user = db.relationship(
        'UserModel',
        back_populates='teams',
        cascade='all, delete-orphan'
    )

    # use for founded_at
    created_at = CreatedAt(db)
    updated_at = UpdatedAt(db)

    def to_json(self):
        return {
            "team_id": self.team_id,
            "user_id": self.user_id,
            "team_name": self.team_name,
            "team_address": self.team_address,
            "championships_won": self.championships_won,
            "coach_name": self.coach_name,
            "user": self.user.to_json() if self.user else None,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }