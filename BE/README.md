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

Auth
- `POST /api/auth/login` — obtain JWT token (OAuth2 password form)

Users
- `GET /api/users/me` — get current user (requires Bearer token)

Incidents
- `POST /api/incidents/report` — create incident (admin/super_admin)
- `GET /api/incidents` — list incidents
- `GET /api/incidents/{incident_id}` — get incident
- `PUT /api/incidents/{incident_id}` — update (super_admin)
- `DELETE /api/incidents/{incident_id}` — delete (super_admin)
- `POST /api/incidents/{incident_id}/evidence` — upload evidence files (admin/super_admin)

Stations (Đồn Biên Phòng)
- `POST /api/stations` — create station (super_admin)
- `GET /api/stations` — list stations
- `GET /api/stations/{station_id}` — get station
- `PUT /api/stations/{station_id}` — update station (super_admin)
- `DELETE /api/stations/{station_id}` — delete station (super_admin)

Admin accounts
- `POST /api/admin/create` — create admin account (super_admin)
- `PUT /api/admin/{username}` — update admin account (super_admin)
- `DELETE /api/admin/{username}` — delete admin account (super_admin)
- `GET /api/admin/admins` — public list of admins

Notes
- This scaffold uses an in-memory user store for now (in `services/user_service.py`). Replace with a database implementation later.
- Configure `ACCESS_TOKEN_EXPIRE_MINUTES` and `SECRET_KEY` in `.env`.