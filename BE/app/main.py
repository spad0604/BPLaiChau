import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.api import api_router
from app.db.migrate import init_db
from app.services.user_service import ensure_default_admin

app = FastAPI(title="BPLaiChau Backend")

# CORS
# Configure via env:
# - CORS_ALLOW_ORIGINS: comma-separated list (e.g. "https://bienphong-3b6d8.web.app,https://*.trycloudflare.com")
# - CORS_ALLOW_ORIGIN_REGEX: regex string (e.g. r"https://.*\.web\.app$")
_origins_raw = os.getenv("CORS_ALLOW_ORIGINS", "").strip()
_allow_origins = [o.strip() for o in _origins_raw.split(",") if o.strip()]
_allow_origin_regex = os.getenv(
	"CORS_ALLOW_ORIGIN_REGEX",
	r"https://.*\.web\.app$|https://.*\.firebaseapp\.com$|https://.*\.trycloudflare\.com$",
)

app.add_middleware(
	CORSMiddleware,
	allow_origins=_allow_origins if _allow_origins else ["*"],
	allow_origin_regex=None if _allow_origins else _allow_origin_regex,
	allow_credentials=False,
	allow_methods=["*"],
	allow_headers=["*"],
)

from fastapi.staticfiles import StaticFiles

app.include_router(api_router, prefix="/api")

# Mount static files
# Ensure static directory exists
os.makedirs("static", exist_ok=True)
app.mount("/static", StaticFiles(directory="static"), name="static")



@app.on_event("startup")
def _startup() -> None:
	# Prepare DB tables if DATABASE_URL/DB_* is configured
	init_db()
	# Ensure default admin account exists
	ensure_default_admin()


@app.get("/")
def root():
	return {"message": "Backend API running"}
