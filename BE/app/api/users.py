from fastapi import APIRouter, Depends
from app.schemas.user import UserOut
from app.core.security import get_current_user

router = APIRouter()


@router.get("/me", response_model=UserOut)
async def read_me(current_user=Depends(get_current_user)):
    return UserOut(username=current_user.username, full_name=current_user.full_name)
