from typing import Dict, List, Optional, Any
from uuid import uuid4
from datetime import datetime

from app.models.incident import Incident
from app.schemas.base_response import BaseResponse


class IncidentService:
    """In-memory incident manager returning `BaseResponse`."""

    def __init__(self) -> None:
        self._incidents: Dict[str, Incident] = {}

    def create(self, payload: Optional[Dict[str, Any]] = None, incident: Optional[Incident] = None) -> BaseResponse:
        try:
            if incident is None:
                if payload is None:
                    return BaseResponse(status=400, message="payload or incident required", data=None)
                incident = Incident(**payload)

            if not incident.incident_id:
                incident.incident_id = uuid4().hex
            if not incident.created_at:
                incident.created_at = datetime.utcnow().isoformat()
            if incident.evidence is None:
                incident.evidence = []

            self._incidents[incident.incident_id] = incident
            return BaseResponse(status=201, message="Incident created", data={"incident": incident.__dict__})
        except Exception as e:
            return BaseResponse(status=500, message=str(e), data=None)

    def get(self, incident_id: str) -> BaseResponse:
        incident = self._incidents.get(incident_id)
        if not incident:
            return BaseResponse(status=404, message="Incident not found", data=None)
        return BaseResponse(status=200, message="OK", data={"incident": incident.__dict__})

    def list(self) -> BaseResponse:
        items = [inc.__dict__ for inc in self._incidents.values()]
        return BaseResponse(status=200, message="OK", data={"items": items})

    def update(self, incident_id: str, updates: Dict[str, Any]) -> BaseResponse:
        existing = self._incidents.get(incident_id)
        if existing is None:
            return BaseResponse(status=404, message="Incident not found", data=None)

        try:
            for k, v in updates.items():
                if hasattr(existing, k):
                    setattr(existing, k, v)
            self._incidents[incident_id] = existing
            return BaseResponse(status=200, message="Incident updated", data={"incident": existing.__dict__})
        except Exception as e:
            return BaseResponse(status=500, message=str(e), data=None)

    def delete(self, incident_id: str) -> BaseResponse:
        if incident_id in self._incidents:
            self._incidents.pop(incident_id)
            return BaseResponse(status=200, message="Incident deleted", data=None)
        return BaseResponse(status=404, message="Incident not found", data=None)


# Export a singleton for simple usage
incident_service = IncidentService()
