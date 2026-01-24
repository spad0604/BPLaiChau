from typing import Optional, Any
from app.schemas.user import UserCreate
from app.models.user import User, UserRole
from app.core.crypto import get_password_hash, verify_password
from app.core.db import try_get_connection
import uuid

# simple in-memory user store
_users: dict = {}


def _db_enabled() -> bool:
    return try_get_connection() is not None


def _row_to_user(row: Any) -> User:
    # row order matches SELECT below
    return User(
        username=row[0],
        hashed_password=row[1],
        user_id=row[2],
        full_name=row[3] or "",
        phone_number=row[4] or "",
        date_of_birth=row[5] or "",
        indentity_card_number=row[6] or "",
        role=UserRole(row[7]) if row[7] else UserRole.ADMIN,
        gender=int(row[8] or 0),
    )


def create_user(user_in: UserCreate) -> User:
    hashed = get_password_hash(user_in.password)
    user_id = str(uuid.uuid4())
    user = User(
        user_id=user_id,
        username=user_in.username,
        hashed_password=hashed,
        full_name=user_in.full_name or "",
        role=user_in.role,
        indentity_card_number=user_in.indentity_card_number or "",
        date_of_birth=user_in.date_of_birth or "",
        phone_number=user_in.phone_number or "",
        gender=user_in.gender or 0,
    )

    conn = try_get_connection()
    if conn is not None:
        try:
            with conn:
                with conn.cursor() as cur:
                    cur.execute(
                        """
                        insert into users (
                            username, user_id, hashed_password, full_name,
                            phone_number, date_of_birth, indentity_card_number,
                            role, gender
                        ) values (%s,%s,%s,%s,%s,%s,%s,%s,%s)
                        """,
                        (
                            user.username,
                            user.user_id,
                            user.hashed_password,
                            user.full_name,
                            user.phone_number,
                            user.date_of_birth,
                            user.indentity_card_number,
                            user.role.value,
                            user.gender,
                        ),
                    )
        finally:
            conn.close()
        return user

    _users[user_in.username] = user
    return user


def get_user_by_username(username: str) -> Optional[User]:
    conn = try_get_connection()
    if conn is not None:
        try:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    select username, hashed_password, user_id, full_name,
                           phone_number, date_of_birth, indentity_card_number,
                           role, gender
                    from users where username = %s
                    """,
                    (username,),
                )
                row = cur.fetchone()
                return _row_to_user(row) if row else None
        except Exception:
            # DB configured but not initialized yet; fall back to in-memory
            return _users.get(username)
        finally:
            conn.close()
    return _users.get(username)


def verify_user_credentials(username: str, password: str) -> bool:
    user = get_user_by_username(username)
    if not user:
        return False

    return verify_password(password, user.hashed_password)


def update_user(username: str, updates: dict) -> Optional[User]:
    user = get_user_by_username(username)
    if not user:
        return None

    # apply updates in-memory object first
    for k, v in updates.items():
        if hasattr(user, k):
            if k == "password":
                user.hashed_password = get_password_hash(v)
            elif k == "role":
                if isinstance(v, str):
                    try:
                        user.role = UserRole(v)
                    except Exception:
                        pass
                else:
                    user.role = v
            else:
                setattr(user, k, v)

    conn = try_get_connection()
    if conn is not None:
        try:
            # map dataclass fields to DB columns
            with conn:
                with conn.cursor() as cur:
                    cur.execute(
                        """
                        update users
                        set hashed_password=%s,
                            full_name=%s,
                            phone_number=%s,
                            date_of_birth=%s,
                            indentity_card_number=%s,
                            role=%s,
                            gender=%s
                        where username=%s
                        """,
                        (
                            user.hashed_password,
                            user.full_name,
                            user.phone_number,
                            user.date_of_birth,
                            user.indentity_card_number,
                            user.role.value,
                            user.gender,
                            username,
                        ),
                    )
        finally:
            conn.close()
        return user

    _users[username] = user
    return user


def delete_user(username: str) -> bool:
    conn = try_get_connection()
    if conn is not None:
        try:
            with conn:
                with conn.cursor() as cur:
                    cur.execute("delete from users where username=%s", (username,))
                    return cur.rowcount > 0
        finally:
            conn.close()
    return _users.pop(username, None) is not None


def list_admins() -> list:
    # return list of users with role ADMIN (not super admin)
    conn = try_get_connection()
    if conn is not None:
        try:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    select username, hashed_password, user_id, full_name,
                           phone_number, date_of_birth, indentity_card_number,
                           role, gender
                    from users where role = %s
                    """,
                    (UserRole.ADMIN.value,),
                )
                rows = cur.fetchall() or []
                return [_row_to_user(r) for r in rows]
        except Exception:
            admins = [u for u in _users.values() if getattr(u, "role", None) == UserRole.ADMIN]
            return admins
        finally:
            conn.close()

    admins = [u for u in _users.values() if getattr(u, "role", None) == UserRole.ADMIN]
    return admins


def ensure_default_admin() -> None:
    """Ensure a default admin account exists for first-time setup.

    Username: admin
    Password: 06042004
    Role: super_admin
    """
    if get_user_by_username("admin"):
        return

    # import here to avoid circular imports
    user_in = UserCreate(
        username="admin",
        password="06042004",
        full_name="Administrator",
        role=UserRole.SUPER_ADMIN,
    )
    create_user(user_in)

