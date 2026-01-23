from dataclasses import dataclass
from typing import List

@dataclass
class Incident:
    incident_id: str = ""
    title: str = ""
    created_at: str = ""
    location: str = ""
    description: str = ""
    results: str = ""
    form_of_punishment: str = ""
    penalty_amount: float = 0.0
    evidence: List[str] = None