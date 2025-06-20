from src.utils.db_utils import CreatedAt, UUIDGenerator, UpdatedAt
from src.extensions import db

class PlayerTeamModel(db.Model):
    __tablename__ = 'player_team_table'

    player_team_id = UUIDGenerator(db, 'player-team')
    player_id = db.Column(db.String, db.ForeignKey('players_table.player_id'), nullable=False)
    team_id = db.Column(db.String, db.ForeignKey('teams_table.team_id', ondelete="CASCADE"), nullable=False)
    is_ban = db.Column(db.Boolean, nullable=False, default=False)

    __table_args__ = (
        db.UniqueConstraint('player_id', 'team_id', name='unique_player_team'),
    )

    teams_where_captain = db.relationship(
        'TeamModel',
        back_populates='team_captain',
        foreign_keys='TeamModel.team_captain_id'
    )
    
    # One-to-Many
    player = db.relationship('PlayerModel', back_populates='my_teams')
    # One-to-Many
    team = db.relationship(
        'TeamModel',
        back_populates='players',
        foreign_keys=[team_id]
    )

    created_at = CreatedAt(db)
    updated_at = UpdatedAt(db)

    def to_json_for_team(self) -> dict:
        return {
            "player_team_id": self.player_team_id,
            "user_id": self.player.user_id,
            "player_id": self.player_id,
            "first_name": self.player.first_name,
            "last_name": self.player.last_name,
            "gender": self.player.gender,
            "birth_date": self.player.birth_date,
            "player_address": self.player.player_address,
            "jersey_name": self.player.jersey_name,
            "jersey_number": self.player.jersey_number,
            "position": self.player.position,
            "profile_image_url": self.player.profile_image_url,
            "is_ban": self.is_ban
        }

    def to_json(self) -> dict:
        return {
            "player_team_id": self.player_team_id,
            "player_id": self.player_id,
            "team_id": self.team_id,
            "player": self.player.to_json() if self.player else None,
            "team": self.team.to_json() if self.team else None,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat()
        }


class TeamModel(db.Model):
    __tablename__ = 'teams_table'

    team_id = UUIDGenerator(db, 'team')

    user_id = db.Column(
        db.String,
        db.ForeignKey('users_table.user_id', ondelete='CASCADE'),
        nullable=False
    )
    # Many-to-One
    user = db.relationship('UserModel', back_populates='teams', single_parent=True)

    active_league_id = db.Column(db.String, db.ForeignKey('leagues_table.league_id'))
    active_league = db.relationship('LeagueModel', uselist=False)

    team_name = db.Column(db.String(100), nullable=False)

    team_address = db.Column(
        db.String(250),
        nullable=False
    )

    contact_number = db.Column(
        db.String(15),
        nullable=False,
    )
    
    team_motto = db.Column(
        db.String(100),
        nullable=True
    )
    
    team_logo_url = db.Column(db.String, nullable=False)
    championships_won = db.Column(db.Integer, nullable=False, default=0)
    coach_name = db.Column(db.String(100), nullable=False)
    assistant_coach_name = db.Column(db.String(100), nullable=True)

    total_wins = db.Column(db.Integer, default=0, nullable=False)
    total_losses = db.Column(db.Integer, default=0, nullable=False)

    team_captain_id = db.Column(
        db.String,
        db.ForeignKey('player_team_table.player_team_id', use_alter=True, name='fk_team_captain_id', deferrable=True),
        nullable=True
    )

    team_captain = db.relationship(
        'PlayerTeamModel',
        uselist=False,
        primaryjoin="TeamModel.team_captain_id == PlayerTeamModel.player_team_id"
    )
    
    def players_to_json_list(self):
        return [player.to_json_for_team() for player in self.players] if self.players else []

    def to_json(self):
        players = [player.to_json_for_team() for player in self.players] if self.players else []
        team_captain = self.team_captain.to_json_for_team() if self.team_captain else None
        return {
            "team_id": self.team_id,
            "user_id": self.user_id,
            "active_league": self.active_league.to_json() if self.active_league else None,
            "team_name": self.team_name,
            "team_address": self.team_address,
            "contact_number": self.contact_number,
            "team_motto": self.team_motto if self.team_motto else None,
            "team_logo_url": self.team_logo_url if self.team_logo_url else None,
            "championships_won": self.championships_won,
            "coach_name": self.coach_name,
            "assistant_coach_name": self.assistant_coach_name if self.assistant_coach_name else None,
            "team_captain": team_captain,
            "players": players,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
        }
    
    # Many-to-Many
    players = db.relationship(
        'PlayerTeamModel',
        back_populates='team',
        cascade='all, delete-orphan',
        foreign_keys=[PlayerTeamModel.team_id],
        passive_deletes=True
    )

    payments = db.relationship('PaymentModel', back_populates='team', cascade="all, delete-orphan")

    league_team = db.relationship(
        'LeagueTeamModel',
        back_populates='team',
        cascade='all, delete-orphan'
    )

    # use for founded_at
    created_at = CreatedAt(db)
    updated_at = UpdatedAt(db)

    
