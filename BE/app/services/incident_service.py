from typing import Dict, List, Optional, Any
from uuid import uuid4
from datetime import datetime
from psycopg2.extras import RealDictCursor, Json

from app.models.incident import Incident
from app.schemas.base_response import BaseResponse
from app.core.db import try_get_connection


class IncidentService:
    """In-memory incident manager returning `BaseResponse`."""

    def __init__(self) -> None:
        self._incidents: Dict[str, Incident] = {}

    def _db(self):
        return try_get_connection()

    def _row_to_incident_dict(self, row: Any) -> Dict[str, Any]:
        if isinstance(row, dict):
            d = dict(row)
            if d.get("created_at") is not None and not isinstance(d.get("created_at"), str):
                d["created_at"] = d["created_at"].isoformat()
            # JSONB comes back already decoded via psycopg2
            if d.get("seized_items") is None:
                d["seized_items"] = []
            if d.get("evidence") is None:
                d["evidence"] = []
            # numeric penalty_amount -> float
            if d.get("penalty_amount") is not None:
                try:
                    d["penalty_amount"] = float(d["penalty_amount"])
                except Exception:
                    pass
            return d
        return row

    def create(self, payload: Optional[Dict[str, Any]] = None, incident: Optional[Incident] = None) -> BaseResponse:
        try:
            if incident is None:
                if payload is None:
                    return BaseResponse(status=400, message="payload or incident required", data=None)
                incident = Incident(**payload)

            if not incident.incident_id:
                incident.incident_id = uuid4().hex
            if not incident.created_at:
                incident.created_at = datetime.utcnow().isoformat()
            # evidence must always be a list
            if incident.evidence is None:
                incident.evidence = []
            if getattr(incident, "seized_items", None) is None:
                incident.seized_items = []
            if getattr(incident, "status", None) is None or not str(getattr(incident, "status", "")).strip():
                incident.status = "Đang thụ lý"

            conn = self._db()
            if conn is not None:
                try:
                    with conn:
                        with conn.cursor(cursor_factory=RealDictCursor) as cur:
                            cur.execute(
                                """
                                insert into incidents (
                                    incident_id, created_at,
                                    station_id, station_name,
                                    incident_type, severity, status,
                                    occurred_at, location, title, description,
                                    handling_measure, prosecuted_behavior, seized_items,
                                    results, form_of_punishment, penalty_amount, note,
                                    evidence
                                ) values (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
                                """,
                                (
                                    incident.incident_id,
                                    incident.created_at,
                                    incident.station_id,
                                    incident.station_name,
                                    incident.incident_type,
                                    incident.severity,
                                    incident.status,
                                    incident.occurred_at,
                                    incident.location,
                                    incident.title,
                                    incident.description,
                                    incident.handling_measure,
                                    incident.prosecuted_behavior,
                                    Json(incident.seized_items or []),
                                    incident.results,
                                    incident.form_of_punishment,
                                    incident.penalty_amount,
                                    incident.note,
                                    Json(incident.evidence or []),
                                ),
                            )
                            cur.execute("select * from incidents where incident_id=%s", (incident.incident_id,))
                            row = cur.fetchone()
                            return BaseResponse(status=201, message="Incident created", data={"incident": self._row_to_incident_dict(row)})
                except Exception as e:
                    return BaseResponse(status=500, message=str(e), data=None)
                finally:
                    conn.close()

            self._incidents[incident.incident_id] = incident
            return BaseResponse(status=201, message="Incident created", data={"incident": incident.__dict__})
        except Exception as e:
            return BaseResponse(status=500, message=str(e), data=None)

    def get(self, incident_id: str) -> BaseResponse:
        conn = self._db()
        if conn is not None:
            try:
                with conn.cursor(cursor_factory=RealDictCursor) as cur:
                    cur.execute("select * from incidents where incident_id=%s", (incident_id,))
                    row = cur.fetchone()
                    if not row:
                        return BaseResponse(status=404, message="Incident not found", data=None)
                    return BaseResponse(status=200, message="OK", data={"incident": self._row_to_incident_dict(row)})
            except Exception as e:
                return BaseResponse(status=500, message=str(e), data=None)
            finally:
                conn.close()

        incident = self._incidents.get(incident_id)
        if not incident:
            return BaseResponse(status=404, message="Incident not found", data=None)
        return BaseResponse(status=200, message="OK", data={"incident": incident.__dict__})

    def list(
        self,
        station_id: str = "",
        year: int = 0,
        status: str = "",
        title: str = "",
    ) -> BaseResponse:
        conn = self._db()
        if conn is not None:
            try:
                with conn.cursor(cursor_factory=RealDictCursor) as cur:
                    where_parts: List[str] = []
                    params: List[Any] = []

                    if station_id:
                        where_parts.append("station_id = %s")
                        params.append(station_id)
                    if year and year > 0:
                        where_parts.append("extract(year from created_at) = %s")
                        params.append(year)
                    if status:
                        where_parts.append("status = %s")
                        params.append(status)
                    if title:
                        where_parts.append("title ilike %s")
                        params.append(f"%{title}%")

                    where_clause = (" where " + " and ".join(where_parts)) if where_parts else ""
                    cur.execute(f"select * from incidents{where_clause} order by created_at desc", params)
                    rows = cur.fetchall() or []
                    items = [self._row_to_incident_dict(r) for r in rows]
                    return BaseResponse(status=200, message="OK", data={"items": items})
            except Exception as e:
                return BaseResponse(status=500, message=str(e), data=None)
            finally:
                conn.close()

        items = [inc.__dict__ for inc in self._incidents.values()]
        return BaseResponse(status=200, message="OK", data={"items": items})

    def stats(
        self,
        station_id: str = "",
        year: int = 0,
        title: str = "",
    ) -> BaseResponse:
        """Compute summary stats for dashboard cards.

        Returns: total, in_progress, urgent, completed_this_month.
        """
        conn = self._db()
        if conn is not None:
            try:
                with conn.cursor() as cur:
                    where_parts: List[str] = []
                    params: List[Any] = []
                    if station_id:
                        where_parts.append("station_id = %s")
                        params.append(station_id)
                    if year and year > 0:
                        where_parts.append("extract(year from created_at) = %s")
                        params.append(year)
                    if title:
                        where_parts.append("title ilike %s")
                        params.append(f"%{title}%")

                    where_clause = (" where " + " and ".join(where_parts)) if where_parts else ""

                    cur.execute(f"select count(*) from incidents{where_clause}", params)
                    total = int(cur.fetchone()[0] or 0)

                    cur.execute(
                        f"select count(*) from incidents{where_clause}{' and ' if where_clause else ' where '}status != %s",
                        params + ["Hoàn thành"],
                    )
                    in_progress = int(cur.fetchone()[0] or 0)

                    cur.execute(
                        f"select count(*) from incidents{where_clause}{' and ' if where_clause else ' where '}severity = %s",
                        params + ["critical"],
                    )
                    urgent = int(cur.fetchone()[0] or 0)

                    cur.execute(
                        f"""
                        select count(*)
                        from incidents
                        {where_clause}
                        {' and ' if where_clause else ' where '}status = %s
                        and date_trunc('month', created_at) = date_trunc('month', now())
                        """,
                        params + ["Hoàn thành"],
                    )
                    completed_this_month = int(cur.fetchone()[0] or 0)

                    return BaseResponse(
                        status=200,
                        message="OK",
                        data={
                            "total": total,
                            "in_progress": in_progress,
                            "urgent": urgent,
                            "completed_this_month": completed_this_month,
                        },
                    )
            except Exception as e:
                return BaseResponse(status=500, message=str(e), data=None)
            finally:
                conn.close()

        # In-memory fallback
        all_items = list(self._incidents.values())
        total = len(all_items)
        in_progress = len([i for i in all_items if (getattr(i, "status", "Đang thụ lý") or "Đang thụ lý") != "Hoàn thành"])
        urgent = len([i for i in all_items if (getattr(i, "severity", "") or "") == "critical"])
        return BaseResponse(
            status=200,
            message="OK",
            data={
                "total": total,
                "in_progress": in_progress,
                "urgent": urgent,
                "completed_this_month": 0,
            },
        )

    def update(self, incident_id: str, updates: Dict[str, Any]) -> BaseResponse:
        conn = self._db()
        if conn is not None:
            try:
                with conn:
                    with conn.cursor(cursor_factory=RealDictCursor) as cur:
                        cur.execute("select * from incidents where incident_id=%s", (incident_id,))
                        existing = cur.fetchone()
                        if not existing:
                            return BaseResponse(status=404, message="Incident not found", data=None)

                        allowed = {
                            "station_id",
                            "station_name",
                            "incident_type",
                            "severity",
                            "status",
                            "occurred_at",
                            "location",
                            "title",
                            "description",
                            "handling_measure",
                            "prosecuted_behavior",
                            "seized_items",
                            "results",
                            "form_of_punishment",
                            "penalty_amount",
                            "note",
                            "evidence",
                        }
                        fields = [(k, updates[k]) for k in updates.keys() if k in allowed]
                        if not fields:
                            return BaseResponse(status=200, message="No changes", data={"incident": self._row_to_incident_dict(existing)})

                        set_parts = []
                        values = []
                        for k, v in fields:
                            if k in {"seized_items", "evidence"}:
                                set_parts.append(f"{k}=%s")
                                values.append(Json(v or []))
                            else:
                                set_parts.append(f"{k}=%s")
                                values.append(v)

                        values.append(incident_id)
                        set_clause = ", ".join(set_parts)
                        cur.execute(f"update incidents set {set_clause} where incident_id=%s", values)
                        cur.execute("select * from incidents where incident_id=%s", (incident_id,))
                        row = cur.fetchone()
                        return BaseResponse(status=200, message="Incident updated", data={"incident": self._row_to_incident_dict(row)})
            except Exception as e:
                return BaseResponse(status=500, message=str(e), data=None)
            finally:
                conn.close()

        existing = self._incidents.get(incident_id)
        if existing is None:
            return BaseResponse(status=404, message="Incident not found", data=None)

        try:
            for k, v in updates.items():
                if hasattr(existing, k):
                    setattr(existing, k, v)
            self._incidents[incident_id] = existing
            return BaseResponse(status=200, message="Incident updated", data={"incident": existing.__dict__})
        except Exception as e:
            return BaseResponse(status=500, message=str(e), data=None)

    def delete(self, incident_id: str) -> BaseResponse:
        conn = self._db()
        if conn is not None:
            try:
                with conn:
                    with conn.cursor() as cur:
                        cur.execute("delete from incidents where incident_id=%s", (incident_id,))
                        if cur.rowcount > 0:
                            return BaseResponse(status=200, message="Incident deleted", data=None)
                        return BaseResponse(status=404, message="Incident not found", data=None)
            except Exception as e:
                return BaseResponse(status=500, message=str(e), data=None)
            finally:
                conn.close()

        if incident_id in self._incidents:
            self._incidents.pop(incident_id)
            return BaseResponse(status=200, message="Incident deleted", data=None)
        return BaseResponse(status=404, message="Incident not found", data=None)


# Export a singleton for simple usage
incident_service = IncidentService()
