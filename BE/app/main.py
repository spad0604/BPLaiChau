from fastapi import FastAPI
from app.api.api import api_router

app = FastAPI(title="BPLaiChau Backend")

app.include_router(api_router, prefix="/api")


@app.get("/")
def root():
	return {"message": "Backend API running"}
