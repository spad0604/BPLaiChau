from datetime import timedelta
from typing import Optional

from app.core.security import create_access_token
from app.services.user_service import verify_user_credentials, get_user_by_username


def authenticate_user(username: str, password: str):
    if not verify_user_credentials(username, password):
        return None
    return get_user_by_username(username)


def create_token_for_user(user, expires_delta: Optional[timedelta] = None) -> str:
    token = create_access_token({"sub": user.username, "id": user.user_id, "role": user.role.value, "full_name": user.full_name}, expires_delta=expires_delta)
    return token
