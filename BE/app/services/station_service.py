from typing import Dict, Optional, Any, List
from uuid import uuid4
from datetime import datetime
from psycopg2.extras import RealDictCursor

from app.models.station import Station
from app.schemas.base_response import BaseResponse
from app.core.db import try_get_connection


class StationService:
    """In-memory station manager returning `BaseResponse`."""

    def __init__(self) -> None:
        self._stations: Dict[str, Station] = {}

    def _db(self):
        return try_get_connection()

    def _row_to_station_dict(self, row: Any) -> Dict[str, Any]:
        # RealDictCursor already returns dict
        if isinstance(row, dict):
            d = dict(row)
            # normalize datetime
            if d.get("created_at") is not None and not isinstance(d.get("created_at"), str):
                d["created_at"] = d["created_at"].isoformat()
            return d
        return row

    def create(self, payload: Dict[str, Any]) -> BaseResponse:
        try:
            station = Station(**payload)
            if not station.station_id:
                station.station_id = uuid4().hex
            if not station.created_at:
                station.created_at = datetime.utcnow().isoformat()

            # basic uniqueness check by code if provided
            if station.code:
                for s in self._stations.values():
                    if s.code == station.code:
                        return BaseResponse(status=400, message="Station code already exists", data=None)

            conn = self._db()
            if conn is not None:
                try:
                    with conn:
                        with conn.cursor(cursor_factory=RealDictCursor) as cur:
                            cur.execute(
                                """
                                insert into stations (station_id, name, code, address, phone, created_at)
                                values (%s,%s,%s,%s,%s,%s)
                                """,
                                (
                                    station.station_id,
                                    station.name,
                                    station.code,
                                    station.address,
                                    station.phone,
                                    station.created_at,
                                ),
                            )
                            cur.execute("select * from stations where station_id=%s", (station.station_id,))
                            row = cur.fetchone()
                            return BaseResponse(status=201, message="Station created", data={"station": self._row_to_station_dict(row)})
                except Exception as e:
                    return BaseResponse(status=500, message=str(e), data=None)
                finally:
                    conn.close()

            self._stations[station.station_id] = station
            return BaseResponse(status=201, message="Station created", data={"station": station.__dict__})
        except Exception as e:
            return BaseResponse(status=500, message=str(e), data=None)

    def get(self, station_id: str) -> BaseResponse:
        conn = self._db()
        if conn is not None:
            try:
                with conn.cursor(cursor_factory=RealDictCursor) as cur:
                    cur.execute("select * from stations where station_id=%s", (station_id,))
                    row = cur.fetchone()
                    if not row:
                        return BaseResponse(status=404, message="Station not found", data=None)
                    return BaseResponse(status=200, message="OK", data={"station": self._row_to_station_dict(row)})
            except Exception as e:
                return BaseResponse(status=500, message=str(e), data=None)
            finally:
                conn.close()

        station = self._stations.get(station_id)
        if not station:
            return BaseResponse(status=404, message="Station not found", data=None)
        return BaseResponse(status=200, message="OK", data={"station": station.__dict__})

    def list(self) -> BaseResponse:
        conn = self._db()
        if conn is not None:
            try:
                with conn.cursor(cursor_factory=RealDictCursor) as cur:
                    cur.execute("select * from stations order by created_at desc")
                    rows = cur.fetchall() or []
                    items = [self._row_to_station_dict(r) for r in rows]
                    return BaseResponse(status=200, message="OK", data={"items": items})
            except Exception as e:
                return BaseResponse(status=500, message=str(e), data=None)
            finally:
                conn.close()

        items = [s.__dict__ for s in self._stations.values()]
        return BaseResponse(status=200, message="OK", data={"items": items})

    def update(self, station_id: str, updates: Dict[str, Any]) -> BaseResponse:
        conn = self._db()
        if conn is not None:
            try:
                with conn:
                    with conn.cursor(cursor_factory=RealDictCursor) as cur:
                        cur.execute("select * from stations where station_id=%s", (station_id,))
                        existing = cur.fetchone()
                        if not existing:
                            return BaseResponse(status=404, message="Station not found", data=None)

                        # build dynamic update
                        allowed = {"name", "code", "address", "phone"}
                        fields = [(k, updates[k]) for k in updates.keys() if k in allowed]
                        if not fields:
                            return BaseResponse(status=200, message="No changes", data={"station": self._row_to_station_dict(existing)})

                        set_clause = ", ".join([f"{k}=%s" for k, _ in fields])
                        values = [v for _, v in fields] + [station_id]
                        cur.execute(f"update stations set {set_clause} where station_id=%s", values)
                        cur.execute("select * from stations where station_id=%s", (station_id,))
                        row = cur.fetchone()
                        return BaseResponse(status=200, message="Station updated", data={"station": self._row_to_station_dict(row)})
            except Exception as e:
                return BaseResponse(status=500, message=str(e), data=None)
            finally:
                conn.close()

        existing = self._stations.get(station_id)
        if existing is None:
            return BaseResponse(status=404, message="Station not found", data=None)

        try:
            # if code changes, ensure uniqueness
            new_code = updates.get("code")
            if new_code and new_code != existing.code:
                for sid, s in self._stations.items():
                    if sid != station_id and s.code == new_code:
                        return BaseResponse(status=400, message="Station code already exists", data=None)

            for k, v in updates.items():
                if hasattr(existing, k):
                    setattr(existing, k, v)
            self._stations[station_id] = existing
            return BaseResponse(status=200, message="Station updated", data={"station": existing.__dict__})
        except Exception as e:
            return BaseResponse(status=500, message=str(e), data=None)

    def delete(self, station_id: str) -> BaseResponse:
        conn = self._db()
        if conn is not None:
            try:
                with conn:
                    with conn.cursor() as cur:
                        cur.execute("delete from stations where station_id=%s", (station_id,))
                        if cur.rowcount > 0:
                            return BaseResponse(status=200, message="Station deleted", data=None)
                        return BaseResponse(status=404, message="Station not found", data=None)
            except Exception as e:
                return BaseResponse(status=500, message=str(e), data=None)
            finally:
                conn.close()

        if station_id in self._stations:
            self._stations.pop(station_id)
            return BaseResponse(status=200, message="Station deleted", data=None)
        return BaseResponse(status=404, message="Station not found", data=None)


station_service = StationService()
