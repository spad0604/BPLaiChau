from fastapi import APIRouter, Depends, HTTPException, status, Response
from fastapi.security import OAuth2PasswordRequestForm
from datetime import timedelta

from app.schemas.base_response import BaseResponse
from app.schemas.user import LoginOutput, UserCreate, UserOut, Token
from app.services.user_service import create_user, get_user_by_username
from app.services.auth_service import authenticate_user, create_token_for_user
from app.core.config import settings

router = APIRouter()

@router.post("/login", response_model=BaseResponse)
def login(response: Response, user_in: OAuth2PasswordRequestForm = Depends()):
    user = authenticate_user(user_in.username, user_in.password)
    if not user:
        response.status_code = status.HTTP_401_UNAUTHORIZED
        return BaseResponse(status=401, message="Incorrect username or password", data=None)
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    token = create_token_for_user(user, expires_delta=access_token_expires)
    return BaseResponse(status=200, message="Login successful", data=LoginOutput(
        access_token=token,
        username=user.username,
        full_name=user.full_name,
        role=user.role.value if hasattr(user.role, "value") else str(user.role or ""),
        date_of_birth=user.date_of_birth,
        phone_number=user.phone_number,
        gender=user.gender
    ).dict()
    )

@router.post("/logout", response_model=BaseResponse)
def logout(username: str):
    return BaseResponse(status=200, message=f"User {username} logged out successfully", data=None)