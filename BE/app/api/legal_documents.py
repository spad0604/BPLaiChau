from fastapi import APIRouter, Depends, UploadFile, File
from typing import Dict, Any

from .role_checker import RoleChecker
from app.models.user import UserRole
from app.schemas.legal_document_schema import LegalDocumentIn
from app.schemas.base_response import BaseResponse
from app.services.legal_document_service import legal_document_service
from app.services.local_storage_service import upload_file

router = APIRouter()


@router.get("")
@router.get("/")
async def list_documents():
    return legal_document_service.list()


@router.get("/{document_id}")
async def get_document(document_id: str):
    return legal_document_service.get(document_id)


@router.post("")
@router.post("/")
async def create_document(document: LegalDocumentIn, user=Depends(RoleChecker([UserRole.SUPER_ADMIN]))):
    payload = document.dict()
    return legal_document_service.create(payload=payload)


@router.put("/{document_id}")
async def update_document(document_id: str, updates: Dict[str, Any], user=Depends(RoleChecker([UserRole.SUPER_ADMIN]))):
    return legal_document_service.update(document_id, updates)


@router.delete("/{document_id}")
async def delete_document(document_id: str, user=Depends(RoleChecker([UserRole.SUPER_ADMIN]))):
    return legal_document_service.delete(document_id)


@router.post("/upload")
async def upload_document_file(file: UploadFile = File(...), user=Depends(RoleChecker([UserRole.SUPER_ADMIN]))):
    """Upload a document file and return the URL"""
    try:
        file.file.seek(0)
    except Exception:
        pass
    
    url = upload_file(file.file, filename=file.filename, folder="bplaichau/legal_documents")
    
    if not url:
        return BaseResponse(status=400, message="Upload failed", data=None)
    
    return BaseResponse(status=200, message="File uploaded", data={"file_url": url})
