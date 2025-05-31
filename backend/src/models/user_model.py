from src.extensions import db, ph
from sqlalchemy import Enum as SqlEnum
from enum import Enum
from sqlalchemy.dialects.postgresql import UUID
import uuid
from src.utils.db_utils import CreatedAt, UpdatedAt

class AccountTypeEnum(Enum):
    PLAYER = "Player"
    TEAM_ACCOUNT = "Team_Account"
    ADMINISTRATOR = "Administrator"
    CITY_ADMINISTRATOR = "City_Administrator"

class UserModel(db.Model):
    __tablename__ = 'users_table'
    
    user_id = db.Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )

    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)

    account_type = db.Column(
        SqlEnum(
            AccountTypeEnum,
            values_callable=lambda x: [e.value for e in x],
            name="account_type_enum"
        ), nullable=False
    )

    def set_account_type(self, account_type_str: str) -> None:
        for account_type in AccountTypeEnum:
            if account_type.value.lower() == account_type_str.lower():
                self.account_type = account_type
                return
        raise ValueError(f"Invalid account type string: {account_type_str}")

    def set_password(self, password_str: str) -> None:
        self.password_hash = ph.hash(password_str)

    def verify_password(self, password_str: str) -> bool:
        try:
            return ph.verify(self.password_hash, password_str)
        except Exception:
            return False
        
    created_at = CreatedAt(db)
    updated_at = UpdatedAt(db)
