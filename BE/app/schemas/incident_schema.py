from pydantic import BaseModel
from typing import List, Optional


class IncidentIn(BaseModel):
    title: str
    description: str
    location: str
    severity: Optional[str] = None
    reported_by: Optional[str] = None
    evidence_urls: Optional[List[str]] = None


class IncidentOut(BaseModel):
    incident_id: str
    title: str
    created_at: str
    location: str
    description: str
    results: Optional[str] = None
    form_of_punishment: Optional[str] = None
    penalty_amount: Optional[float] = 0.0
    evidence: Optional[List[str]] = None
