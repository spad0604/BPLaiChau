from pydantic import BaseModel
from typing import Optional

class BaseResponse(BaseModel):
    status: int
    message: str
    data: Optional[dict] = None