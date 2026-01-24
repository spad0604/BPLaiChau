from pydantic import BaseModel
from typing import List, Optional


class SeizedItem(BaseModel):
    name: str
    quantity: Optional[float] = None
    unit: Optional[str] = ""
    note: Optional[str] = ""


class IncidentIn(BaseModel):
    # Ownership/Unit
    station_id: Optional[str] = ""
    station_name: Optional[str] = ""

    # Classification
    incident_type: Optional[str] = "criminal"  # criminal | administrative
    severity: Optional[str] = "medium"  # low | medium | high | critical

    status: Optional[str] = "Đang thụ lý"

    # Time/Place
    occurred_at: Optional[str] = ""
    location: str

    # Content (legacy required fields kept)
    title: str
    description: str

    # Criminal-case fields
    handling_measure: Optional[str] = ""
    prosecuted_behavior: Optional[str] = ""
    seized_items: Optional[List[SeizedItem]] = None

    # Administrative-case fields
    results: Optional[str] = ""
    form_of_punishment: Optional[str] = ""
    penalty_amount: Optional[float] = 0.0
    note: Optional[str] = ""

    evidence: Optional[List[str]] = None


class IncidentOut(BaseModel):
    incident_id: str
    created_at: str

    station_id: Optional[str] = ""
    station_name: Optional[str] = ""
    incident_type: Optional[str] = "criminal"
    severity: Optional[str] = "medium"
    status: Optional[str] = "Đang thụ lý"
    occurred_at: Optional[str] = ""

    location: str

    title: str
    description: str
    handling_measure: Optional[str] = ""
    prosecuted_behavior: Optional[str] = ""
    seized_items: Optional[List[SeizedItem]] = None

    results: Optional[str] = ""
    form_of_punishment: Optional[str] = ""
    penalty_amount: Optional[float] = 0.0
    note: Optional[str] = ""

    evidence: Optional[List[str]] = None
