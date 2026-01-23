from fastapi import Depends
from app.core.security import get_current_user
from app.schemas.base_response import BaseResponse
from app.models.user import User
from typing import List
from app.models.user import UserRole

class RoleChecker:
    def __init__(self, allowed_roles: List[UserRole]) -> None:
        self.allowed_roles = allowed_roles
    def __call__(self, user: User = Depends(get_current_user)) -> bool:
        if user.role not in self.allowed_roles:
            return BaseResponse(status=403, message="Operation not permitted", data=None)
        return user