from dataclasses import dataclass
from enum import Enum

class UserRole(str, Enum):
    SUPER_ADMIN = "super_admin"
    ADMIN = "admin"
    
@dataclass
class User:
    username: str
    hashed_password: str
    user_id: str = ""
    full_name: str = ""
    phone_number: str = ""
    date_of_birth: str = ""
    indentity_card_number: str = ""
    role: UserRole = UserRole.ADMIN
    gender: int = 0  # 0: Female, 1: Male