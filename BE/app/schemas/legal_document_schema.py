from pydantic import BaseModel
from typing import Optional


class LegalDocumentIn(BaseModel):
    title: str
    description: Optional[str] = ""
    file_url: str
    file_type: Optional[str] = ""


class LegalDocumentOut(BaseModel):
    document_id: str
    title: str
    description: str
    file_url: str
    file_type: str
    created_at: str
