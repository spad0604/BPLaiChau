from typing import Any, Dict, List, Optional
from uuid import uuid4
from psycopg2.extras import RealDictCursor

from app.core.db import try_get_connection
from app.schemas.base_response import BaseResponse
from app.services.local_storage_service import upload_file


class BackgroundBannerService:
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
                    cur.execute("select * from background_banners order by created_at desc")
                    rows = cur.fetchall() or []
                    return BaseResponse(status=200, message="OK", data={"items": [self._row_to_dict(r) for r in rows]})
            except Exception as e:
                return BaseResponse(status=500, message=str(e), data=None)
            finally:
                conn.close()

        return BaseResponse(status=200, message="OK", data={"items": list(self._memory)})

    def create(self, image_url: str, banner_title: str = "") -> BaseResponse:
        banner_id = uuid4().hex
        record = {"banner_id": banner_id, "image_url": image_url, "banner_title": banner_title or ""}

        conn = self._db()
        if conn is not None:
            try:
                with conn:
                    with conn.cursor(cursor_factory=RealDictCursor) as cur:
                        cur.execute(
                            """
                            insert into background_banners (banner_id, image_url, banner_title)
                            values (%s, %s, %s)
                            """,
                            (banner_id, image_url, banner_title or ""),
                        )
                        cur.execute("select * from background_banners where banner_id=%s", (banner_id,))
                        row = cur.fetchone()
                        return BaseResponse(status=201, message="Banner created", data={"banner": self._row_to_dict(row)})
            except Exception as e:
                return BaseResponse(status=500, message=str(e), data=None)
            finally:
                conn.close()

        self._memory.append(record)
        return BaseResponse(status=201, message="Banner created", data={"banner": record})

    def create_from_upload(self, file_obj, filename: Optional[str] = None, banner_title: str = "") -> BaseResponse:
        url = upload_file(file_obj, filename=filename, folder="bplaichau/banners")
        if not url:
            return BaseResponse(status=400, message="Upload failed", data=None)
        return self.create(image_url=url, banner_title=banner_title)

    def delete(self, banner_id: str) -> BaseResponse:
        conn = self._db()
        if conn is not None:
            try:
                with conn:
                    with conn.cursor() as cur:
                        cur.execute("delete from background_banners where banner_id=%s", (banner_id,))
                        if cur.rowcount == 0:
                            return BaseResponse(status=404, message="Banner not found", data=None)
                return BaseResponse(status=200, message="Banner deleted", data=None)
            except Exception as e:
                return BaseResponse(status=500, message=str(e), data=None)
            finally:
                conn.close()

        before = len(self._memory)
        self._memory = [b for b in self._memory if b.get("banner_id") != banner_id]
        if len(self._memory) == before:
            return BaseResponse(status=404, message="Banner not found", data=None)
        return BaseResponse(status=200, message="Banner deleted", data=None)


background_banner_service = BackgroundBannerService()