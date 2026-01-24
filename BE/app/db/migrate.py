from app.core.db import try_get_connection


def init_db() -> None:
    """Create minimal tables if DATABASE_URL/DB_* is configured.

    This is intentionally lightweight (no external migration tool).
    """
    conn = try_get_connection()
    if conn is None:
        return

    try:
        with conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    create table if not exists users (
                        username text primary key,
                        user_id text not null,
                        hashed_password text not null,
                        full_name text default '',
                        phone_number text default '',
                        date_of_birth text default '',
                        indentity_card_number text default '',
                        role text not null,
                        gender int default 0,
                        created_at timestamptz default now()
                    );
                    """
                )

                cur.execute(
                    """
                    create table if not exists stations (
                        station_id text primary key,
                        name text not null,
                        code text default '' unique,
                        address text default '',
                        phone text default '',
                        created_at timestamptz default now()
                    );
                    """
                )

                cur.execute(
                    """
                    create table if not exists incidents (
                        incident_id text primary key,
                        created_at timestamptz default now(),

                        station_id text default '',
                        station_name text default '',

                        incident_type text default 'criminal',
                        severity text default 'medium',
                        status text default 'Đang thụ lý',

                        occurred_at text default '',
                        location text not null,
                        title text not null,
                        description text not null,

                        handling_measure text default '',
                        prosecuted_behavior text default '',
                        seized_items jsonb default '[]'::jsonb,

                        results text default '',
                        form_of_punishment text default '',
                        penalty_amount numeric default 0,
                        note text default '',

                        evidence jsonb default '[]'::jsonb
                    );
                    """
                )

                cur.execute(
                    """
                    create table if not exists background_banners (
                        banner_id text primary key,
                        image_url text not null,
                        banner_title text default '',
                        created_at timestamptz default now()
                    );
                    """
                )

                # Backfill/upgrade: add status column if table already existed
                cur.execute("alter table incidents add column if not exists status text default 'Đang thụ lý';")
    finally:
        conn.close()
