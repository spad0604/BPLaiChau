from pydantic import BaseModel
from typing import Optional
from app.models.user import UserRole


class UserCreate(BaseModel):
    username: str
    password: str
    full_name: Optional[str] = None
    indentity_card_number: Optional[str] = None
    date_of_birth: Optional[str] = None
    phone_number: Optional[str] = None
    gender: Optional[int] = None
    role: Optional[UserRole] = UserRole.ADMIN


class UserInDB(BaseModel):
    username: str
    hashed_password: str
    full_name: Optional[str] = None


class UserOut(BaseModel):
    username: str
    full_name: Optional[str] = None
    date_of_birth: Optional[str] = None
    phone_number: Optional[str] = None
    gender: Optional[int] = None

class LoginOutput(BaseModel):
    access_token: str
    username: str
    full_name: str
    role: str
    date_of_birth: Optional[str] = None
    phone_number: Optional[str] = None
    gender: Optional[int] = None

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    username: Optional[str] = None
