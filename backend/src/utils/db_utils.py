from datetime import datetime, timezone
import uuid
from sqlalchemy.dialects.postgresql import UUID

def CreatedAt(db):
    return db.Column(
        db.DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )

def UpdatedAt(db):
    return db.Column(
        db.DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False
    )

def UUIDGenerator(db, prefix):
    def generate_uid():
        return f"{prefix}-{uuid.uuid4()}"
    return db.Column(
        db.String,
        primary_key=True,
        default=generate_uid
    )