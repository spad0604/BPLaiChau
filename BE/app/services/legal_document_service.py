from typing import Any, Dict, List, Optional
from uuid import uuid4
from psycopg2.extras import RealDictCursor

from app.core.db import try_get_connection
from app.schemas.base_response import BaseResponse


class LegalDocumentService:
    def __init__(self) -> None:
        self._memory: List[Dict[str, Any]] = []

    def _db(self):
        return try_get_connection()

    def _row_to_dict(self, row: Any) -> Dict[str, Any]:
        if isinstance(row, dict):
            d = dict(row)
            if d.get("created_at") is not None and not isinstance(d.get("created_at"), str):
                try:
                    d["created_at"] = d["created_at"].isoformat()
                except Exception:
                    pass
            return d
        return row

    def list(self) -> BaseResponse:
        conn = self._db()
        if conn is not None:
            try:
                with conn.cursor(cursor_factory=RealDictCursor) as cur:
                    cur.execute("select * from legal_documents order by created_at desc")
                    rows = cur.fetchall() or []
                    return BaseResponse(status=200, message="OK", data={"items": [self._row_to_dict(r) for r in rows]})
            except Exception as e:
                return BaseResponse(status=500, message=str(e), data=None)
            finally:
                conn.close()

        return BaseResponse(status=200, message="OK", data={"items": list(self._memory)})

    def get(self, document_id: str) -> BaseResponse:
        conn = self._db()
        if conn is not None:
            try:
                with conn.cursor(cursor_factory=RealDictCursor) as cur:
                    cur.execute("select * from legal_documents where document_id=%s", (document_id,))
                    row = cur.fetchone()
                    if row:
                        return BaseResponse(status=200, message="OK", data={"document": self._row_to_dict(row)})
                    return BaseResponse(status=404, message="Document not found", data=None)
            except Exception as e:
                return BaseResponse(status=500, message=str(e), data=None)
            finally:
                conn.close()

        doc = next((d for d in self._memory if d.get("document_id") == document_id), None)
        if doc:
            return BaseResponse(status=200, message="OK", data={"document": doc})
        return BaseResponse(status=404, message="Document not found", data=None)

    def create(self, payload: Dict[str, Any]) -> BaseResponse:
        document_id = uuid4().hex
        record = {
            "document_id": document_id,
            "title": payload.get("title", ""),
            "description": payload.get("description", ""),
            "file_url": payload.get("file_url", ""),
            "file_type": payload.get("file_type", ""),
        }

        conn = self._db()
        if conn is not None:
            try:
                with conn:
                    with conn.cursor(cursor_factory=RealDictCursor) as cur:
                        cur.execute(
                            """
                            insert into legal_documents (document_id, title, description, file_url, file_type)
                            values (%s, %s, %s, %s, %s)
                            """,
                            (document_id, record["title"], record["description"], record["file_url"], record["file_type"]),
                        )
                        cur.execute("select * from legal_documents where document_id=%s", (document_id,))
                        row = cur.fetchone()
                        return BaseResponse(status=201, message="Document created", data={"document": self._row_to_dict(row)})
            except Exception as e:
                return BaseResponse(status=500, message=str(e), data=None)
            finally:
                conn.close()

        self._memory.append(record)
        return BaseResponse(status=201, message="Document created", data={"document": record})

    def update(self, document_id: str, updates: Dict[str, Any]) -> BaseResponse:
        conn = self._db()
        if conn is not None:
            try:
                with conn:
                    with conn.cursor(cursor_factory=RealDictCursor) as cur:
                        set_parts = []
                        vals = []
                        for k, v in updates.items():
                            set_parts.append(f"{k}=%s")
                            vals.append(v)
                        vals.append(document_id)
                        cur.execute(f"update legal_documents set {', '.join(set_parts)} where document_id=%s", vals)
                        if cur.rowcount == 0:
                            return BaseResponse(status=404, message="Document not found", data=None)
                        cur.execute("select * from legal_documents where document_id=%s", (document_id,))
                        row = cur.fetchone()
                        return BaseResponse(status=200, message="Document updated", data={"document": self._row_to_dict(row)})
            except Exception as e:
                return BaseResponse(status=500, message=str(e), data=None)
            finally:
                conn.close()

        doc = next((d for d in self._memory if d.get("document_id") == document_id), None)
        if doc:
            doc.update(updates)
            return BaseResponse(status=200, message="Document updated", data={"document": doc})
        return BaseResponse(status=404, message="Document not found", data=None)

    def delete(self, document_id: str) -> BaseResponse:
        conn = self._db()
        if conn is not None:
            try:
                with conn:
                    with conn.cursor() as cur:
                        cur.execute("delete from legal_documents where document_id=%s", (document_id,))
                        if cur.rowcount == 0:
                            return BaseResponse(status=404, message="Document not found", data=None)
                return BaseResponse(status=200, message="Document deleted", data=None)
            except Exception as e:
                return BaseResponse(status=500, message=str(e), data=None)
            finally:
                conn.close()

        before = len(self._memory)
        self._memory = [d for d in self._memory if d.get("document_id") != document_id]
        if len(self._memory) == before:
            return BaseResponse(status=404, message="Document not found", data=None)
        return BaseResponse(status=200, message="Document deleted", data=None)


legal_document_service = LegalDocumentService()
