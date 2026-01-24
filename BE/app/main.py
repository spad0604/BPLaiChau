from fastapi import FastAPI
from app.api.api import api_router
from app.db.migrate import init_db
from app.services.user_service import ensure_default_admin

app = FastAPI(title="BPLaiChau Backend")

app.include_router(api_router, prefix="/api")


@app.on_event("startup")
def _startup() -> None:
	# Prepare DB tables if DATABASE_URL/DB_* is configured
	init_db()
	# Ensure default admin account exists
	ensure_default_admin()


@app.get("/")
def root():
	return {"message": "Backend API running"}
