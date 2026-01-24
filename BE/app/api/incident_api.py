from fastapi import APIRouter, Depends, UploadFile, File, Query
from typing import List, Dict, Any

from .role_checker import RoleChecker
from app.models.user import UserRole
from app.schemas.incident_schema import IncidentIn
from app.schemas.base_response import BaseResponse
from app.services.incident_service import incident_service
from app.services.cloudinary_service import upload_file

router = APIRouter()


@router.get("/stats")
async def incident_stats(
    station_id: str = Query(default=""),
    year: int = Query(default=0),
    title: str = Query(default=""),
):
    return incident_service.stats(station_id=station_id, year=year, title=title)


@router.post("/report")
async def create_incident(incident: IncidentIn, user=Depends(RoleChecker([UserRole.ADMIN, UserRole.SUPER_ADMIN]))):
    payload = incident.dict()
    # allow pre-provided evidence urls
    res: BaseResponse = incident_service.create(payload=payload)
    return res


@router.get("/{incident_id}")
async def get_incident(incident_id: str):
    return incident_service.get(incident_id)


@router.get("")
@router.get("/")
async def list_incidents(
    station_id: str = Query(default=""),
    year: int = Query(default=0),
    status: str = Query(default=""),
    title: str = Query(default=""),
):
    return incident_service.list(station_id=station_id, year=year, status=status, title=title)


@router.put("/{incident_id}")
async def update_incident(incident_id: str, updates: Dict[str, Any], user=Depends(RoleChecker([UserRole.SUPER_ADMIN]))):
    return incident_service.update(incident_id, updates)


@router.delete("/{incident_id}")
async def delete_incident(incident_id: str, user=Depends(RoleChecker([UserRole.SUPER_ADMIN]))):
    return incident_service.delete(incident_id)


@router.post("/{incident_id}/evidence")
async def upload_evidence(incident_id: str, files: List[UploadFile] = File(...), user=Depends(RoleChecker([UserRole.ADMIN, UserRole.SUPER_ADMIN]))):
    # upload files to Cloudinary and append urls to incident.evidence
    uploaded_urls = []
    for f in files:
        url = upload_file(f.file)
        if url:
            uploaded_urls.append(url)

    if not uploaded_urls:
        return BaseResponse(status=400, message="No files uploaded", data=None)

    # fetch existing
    existing_resp = incident_service.get(incident_id)
    if existing_resp.status != 200 or not existing_resp.data:
        return BaseResponse(status=404, message="Incident not found", data=None)

    incident = existing_resp.data.get("incident")
    evidence = incident.get("evidence") or []
    evidence.extend(uploaded_urls)
    update_resp = incident_service.update(incident_id, {"evidence": evidence})
    return update_resp

