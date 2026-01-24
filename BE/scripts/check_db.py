import sys
import traceback

# Ensure project path is importable
sys.path.insert(0, r"d:\BPLaiChau\BE")

def main():
    try:
        from app.core.db import try_get_connection
        from app.core.config import settings
        print('DATABASE_URL (env raw):', settings.DATABASE_URL)
        print('DB_HOST:', settings.DB_HOST)
        print('DB_USER:', settings.DB_USER)
        print('DB_NAME:', settings.DB_NAME)
        # Use get_connection to capture errors
        from app.core.db import get_connection
        try:
            conn = get_connection()
            print('connected', bool(conn))
        except Exception as e:
            print('get_connection failed:', repr(e))
            return
            return
        cur = conn.cursor()
        cur.execute("select tablename from pg_tables where schemaname='public' order by tablename;")
        rows = cur.fetchall()
        print('tables:', rows)
        # show first few rows from users if present
        cur.execute("select username, user_id from users limit 5;")
        try:
            users = cur.fetchall()
            print('sample users:', users)
        except Exception:
            print('users table missing or query failed')
        conn.close()
    except Exception:
        traceback.print_exc()

if __name__ == '__main__':
    main()
