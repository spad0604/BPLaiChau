from typing import Optional
from app.schemas.user import UserCreate
from app.models.user import User, UserRole
from app.core.crypto import get_password_hash, verify_password
import uuid

# simple in-memory user store
_users: dict = {}


def create_user(user_in: UserCreate) -> User:
    hashed = get_password_hash(user_in.password)
    user_id = str(uuid.uuid4())
    user = User(user_id=user_id, username=user_in.username, hashed_password=hashed, full_name=user_in.full_name or "", role=user_in.role, indentity_card_number=user_in.indentity_card_number or "", date_of_birth=user_in.date_of_birth or "", phone_number=user_in.phone_number or "", gender=user_in.gender or 0)
    _users[user_in.username] = user
    return user


def get_user_by_username(username: str) -> Optional[User]:
    return _users.get(username)


def verify_user_credentials(username: str, password: str) -> bool:
    user = get_user_by_username(username)
    if not user:
        return False

    return verify_password(password, user.hashed_password)


def update_user(username: str, updates: dict) -> Optional[User]:
    user = _users.get(username)
    if not user:
        return None
    for k, v in updates.items():
        if hasattr(user, k):
            # prevent replacing password directly without hashing
            if k == "password":
                user.hashed_password = get_password_hash(v)
            elif k == "role":
                # accept either enum or string
                if isinstance(v, str):
                    try:
                        user.role = UserRole(v)
                    except Exception:
                        pass
                else:
                    user.role = v
            else:
                setattr(user, k, v)
    _users[username] = user
    return user


def delete_user(username: str) -> bool:
    return _users.pop(username, None) is not None


def list_admins() -> list:
    # return list of users with role ADMIN (not super admin)
    admins = [u for u in _users.values() if getattr(u, "role", None) == UserRole.ADMIN]
    return admins
