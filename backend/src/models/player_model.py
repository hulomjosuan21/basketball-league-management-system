from src.extensions import db, ph
import uuid
from sqlalchemy.dialects.postgresql import UUID
from src.utils.db_utils import CreatedAt, UpdatedAt

class PlayerModel(db.Model):
    __tablename__ = 'players_table'

    player_id = db.Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )

    user_id = db.Column(
        UUID(as_uuid=True),
        db.ForeignKey('users_table.user_id'),
        unique=True,
        nullable=False
    )

    user = db.relationship('UserModel', backref=db.backref('player', uselist=False))

    created_at = CreatedAt(db)
    updated_at = UpdatedAt(db)