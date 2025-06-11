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

    # Many-to-One
    user = db.relationship('UserModel', back_populates='teams', single_parent=True)

    # Many-to-Many
    players = db.relationship('PlayerTeamModel', back_populates='team', cascade='all, delete-orphan')

    league_registrations = db.relationship(
        'LeagueTeamModel',
        back_populates='team',
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
            "players": [assoc.player.to_json() for assoc in self.players] if self.players else [],
            "league": [assoc.league.to_json() for assoc in self.league_registrations] if self.league_registrations else [],
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
    
class PlayerTeamModel(db.Model):
    __tablename__ = 'player_team_table'

    player_team_id = UUIDGenerator(db, 'player-team')
    player_id = db.Column(db.String, db.ForeignKey('players_table.player_id'))
    team_id = db.Column(db.String, db.ForeignKey('teams_table.team_id'))

    __table_args__ = (
        db.UniqueConstraint('player_id', 'team_id', name='unique_player_team'),
    )
    
    # One-to-Many
    player = db.relationship('PlayerModel', back_populates='my_teams')
    # One-to-Many
    team = db.relationship('TeamModel', back_populates='players')

    created_at = CreatedAt(db)
    updated_at = UpdatedAt(db)

    def to_json(self) -> dict:
        return {
            "player_team_id": self.player_team_id,
            "player_id": self.player_id,
            "team_id": self.team_id,
            "player": self.player.to_json() if self.player else None,
            "team": self.team.to_json() if self.team else None,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
