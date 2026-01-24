from pydantic import BaseModel
from typing import Optional


class StationIn(BaseModel):
    name: str
    code: Optional[str] = ""
    address: Optional[str] = ""
    phone: Optional[str] = ""


class StationOut(BaseModel):
    station_id: str
    name: str
    code: Optional[str] = ""
    address: Optional[str] = ""
    phone: Optional[str] = ""
    created_at: str
