from fastapi import APIRouter
from .auth import router as auth_router
from .users import router as users_router
from .admin import router as admin_router
from .incident_api import router as incident_router
from .stations import router as stations_router
from .banners import router as banners_router
from .legal_documents import router as legal_documents_router

api_router = APIRouter()

api_router.include_router(auth_router, prefix="/auth", tags=["auth"])
api_router.include_router(users_router, prefix="/users", tags=["users"])
api_router.include_router(admin_router, prefix="/admin", tags=["admin"])
api_router.include_router(incident_router, prefix="/incidents", tags=["incidents"])
api_router.include_router(stations_router, prefix="/stations", tags=["stations"])
api_router.include_router(banners_router, prefix="/banners", tags=["banners"])
api_router.include_router(legal_documents_router, prefix="/legal-documents", tags=["legal-documents"])
