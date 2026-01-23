from typing import Optional
import psycopg2
from psycopg2.extensions import connection as _connection
from core.config import settings


def get_connection() -> Optional[_connection]:
    """Return a psycopg2 connection using settings parsed from environment.

    Uses either SETTINGS.DATABASE_URL or individual DB_* settings.
    """
    user = settings.DB_USER
    password = settings.DB_PASSWORD
    host = settings.DB_HOST
    port = settings.DB_PORT
    dbname = settings.DB_NAME

    # If any part is missing, try to fall back to DATABASE_URL (already parsed in config)
    if not (user and password and host and dbname):
        # cannot connect without required fields
        raise RuntimeError("Database configuration incomplete. Set DATABASE_URL or DB_USER/DB_PASSWORD/DB_HOST/DB_NAME in .env")

    conn = psycopg2.connect(user=user, password=password, host=host, port=port or 5432, dbname=dbname)
    return conn
