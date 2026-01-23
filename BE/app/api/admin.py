from fastapi import APIRouter, Depends
from typing import List, Dict, Any

from .role_checker import RoleChecker
from app.models.user import UserRole
from app.schemas.base_response import BaseResponse
from app.schemas.user import UserCreate
from app.services.user_service import create_user, update_user, delete_user, list_admins, get_user_by_username

router = APIRouter()


@router.post("/create", response_model=BaseResponse)
def create_account(user_in: UserCreate, current=Depends(RoleChecker([UserRole.SUPER_ADMIN]))):
    if get_user_by_username(user_in.username):
        return BaseResponse(status=400, message="Username already exists", data=None)
    user = create_user(user_in)
    return BaseResponse(status=201, message="Account created", data={"username": user.username, "role": user.role})


@router.put("/{username}", response_model=BaseResponse)
def update_account(username: str, updates: Dict[str, Any], current=Depends(RoleChecker([UserRole.SUPER_ADMIN]))):
    user = update_user(username, updates)
    if not user:
        return BaseResponse(status=404, message="User not found", data=None)
    return BaseResponse(status=200, message="User updated", data={"username": user.username, "role": user.role})


@router.delete("/{username}", response_model=BaseResponse)
def delete_account(username: str, current=Depends(RoleChecker([UserRole.SUPER_ADMIN]))):
    ok = delete_user(username)
    if not ok:
        return BaseResponse(status=404, message="User not found", data=None)
    return BaseResponse(status=200, message="User deleted", data=None)


@router.get("/admins", response_model=List[dict])
def public_list_admins():
    admins = list_admins()
    # return minimal public info
    return [{"username": u.username, "full_name": u.full_name} for u in admins]
