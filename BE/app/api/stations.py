from fastapi import APIRouter, Depends
from typing import Dict, Any

from .role_checker import RoleChecker
from app.models.user import UserRole
from app.schemas.station_schema import StationIn
from app.services.station_service import station_service

router = APIRouter()


@router.post("", dependencies=[Depends(RoleChecker([UserRole.SUPER_ADMIN]))])
@router.post("/", dependencies=[Depends(RoleChecker([UserRole.SUPER_ADMIN]))])
def create_station(station_in: StationIn):
    return station_service.create(station_in.dict())


@router.get("/{station_id}")
def get_station(station_id: str):
    return station_service.get(station_id)


@router.get("")
@router.get("/")
def list_stations():
    return station_service.list()


@router.put("/{station_id}", dependencies=[Depends(RoleChecker([UserRole.SUPER_ADMIN]))])
def update_station(station_id: str, updates: Dict[str, Any]):
    return station_service.update(station_id, updates)


@router.delete("/{station_id}", dependencies=[Depends(RoleChecker([UserRole.SUPER_ADMIN]))])
def delete_station(station_id: str):
    return station_service.delete(station_id)
