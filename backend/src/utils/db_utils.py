from datetime import datetime, timezone
import uuid
from sqlalchemy.dialects.postgresql import UUID
from enum import Enum

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

class AccountTypeEnum(Enum):
    PLAYER = "Player"
    TEAM_CREATOR = "Team_Creator"
    LOCAL_ADMINISTRATOR = "League_Administrator:Local",
    LGU_ADMINISTRATOR = "League_Administrator:LGU",
    SYSTEM = "System"

def create_account_type_enum(db):
    return db.Enum(
        *(member.value for member in AccountTypeEnum),
        name="account_type_enum"
    )