from src.extensions import db, ph
from src.utils.db_utils import CreatedAt, UUIDGenerator, UpdatedAt

class PlayerModel(db.Model):
    __tablename__ = 'players_table'

    player_id = UUIDGenerator(db,'player')

    user_id = db.Column(
        db.String,
        db.ForeignKey('users_table.user_id'),
        unique=True,
        nullable=False
    )

    user = db.relationship('UserModel', back_populates='player')

    created_at = CreatedAt(db)
    updated_at = UpdatedAt(db)