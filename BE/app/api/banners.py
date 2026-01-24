from fastapi import APIRouter, Depends, UploadFile, File, Form

from .role_checker import RoleChecker
from app.models.user import UserRole
from app.services.background_banner_service import background_banner_service

router = APIRouter()


@router.get("")
@router.get("/")
def list_banners():
    """Public: used by the login screen to rotate banners."""
    return background_banner_service.list()


@router.post("")
@router.post("/")
def upload_banner(
    file: UploadFile = File(...),
    banner_title: str = Form(default=""),
    user=Depends(RoleChecker([UserRole.SUPER_ADMIN])),
):
    try:
        try:
            file.file.seek(0)
        except Exception:
            pass
        return background_banner_service.create_from_upload(file.file, filename=file.filename, banner_title=banner_title)
    finally:
        try:
            file.file.close()
        except Exception:
            pass


@router.delete("/{banner_id}")
def delete_banner(banner_id: str, user=Depends(RoleChecker([UserRole.SUPER_ADMIN]))):
    return background_banner_service.delete(banner_id)
