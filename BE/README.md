# BPLaiChau Backend (FastAPI)

Minimal scaffold for a FastAPI backend with JWT authentication.

Quick start

1. Create a virtual environment and install dependencies:

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

2. Copy `.env.example` to `.env` and set a secure `SECRET_KEY`.

3. Run the app:

```bash
uvicorn main:app --reload --port 8000
```

Endpoints
- `POST /api/auth/register` — register new user
- `POST /api/auth/token` — obtain JWT token (OAuth2 password form)
- `GET /api/users/me` — get current user (requires Bearer token)

Notes
- This scaffold uses an in-memory user store for now (in `services/user_service.py`). Replace with a database implementation later.
- Configure `ACCESS_TOKEN_EXPIRE_MINUTES` and `SECRET_KEY` in `.env`.