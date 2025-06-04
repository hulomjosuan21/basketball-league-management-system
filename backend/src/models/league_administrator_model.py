from src.utils.db_utils import CreatedAt, UUIDGenerator, UpdatedAt
from src.extensions import db

class LeagueAdministratorModel(db.Model):
    __tablename__ = 'league_administrator_table'

    league_administrator_id = UUIDGenerator(db,'league_administrator')

    user_id = db.Column(
        db.String,
        db.ForeignKey('users_table.user_id'),
        unique=True,
        nullable=False
    )

    organization_type = db.Column(
        db.String,
        nullable=False
    )

    organization_name = db.Column(
        db.String(200),
        nullable=False
    )

    contact_number = db.Column(
        db.String(15),
        nullable=True
    )

    barangay_name = db.Column(
        db.String(100),
        nullable=False
    )

    province_name = db.Column(
        db.String(100),
        nullable=False
    )

    organization_photo_url = db.Column(
        db.String,
        nullable=True
    )

    organization_logo_url = db.Column(
        db.String,
        nullable=True
    )

    user = db.relationship('UserModel', backref=db.backref('league_administrator', uselist=False))

    created_at = CreatedAt(db)
    updated_at = UpdatedAt(db)

    def toJson(self) -> dict:
        return {
            "league_administrator_id": self.league_administrator_id,
            "user_id": self.user_id,
            "organization_type": self.organization_type,
            "organization_name": self.organization_name,
            "barangay_name": self.barangay_name,
            "province_name": self.province_name,
            "organization_photo_url": self.organization_photo_url,
            "organization_logo_url": self.organization_logo_url,
            "user": self.user.to_json() if self.user else None,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }