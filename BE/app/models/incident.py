from dataclasses import dataclass, field
from typing import List, Dict, Any

@dataclass
class Incident:
    incident_id: str = ""
    created_at: str = ""

    # Ownership/Unit
    station_id: str = ""  # Đồn Biên Phòng
    station_name: str = ""  # optional denormalized name

    # Classification
    incident_type: str = "criminal"  # criminal | administrative
    severity: str = "medium"  # low | medium | high | critical

    # Workflow
    status: str = "Đang thụ lý"  # Đang thụ lý | Hoàn thành

    # Time/Place
    occurred_at: str = ""  # e.g. 2025-01-15T10:30:00Z or a simple date string
    location: str = ""

    # Content (kept legacy title/description to avoid breaking FE)
    title: str = ""  # short summary
    description: str = ""  # detailed content

    # Criminal-case specific
    handling_measure: str = ""  # Biện pháp giải quyết
    prosecuted_behavior: str = ""  # Khởi tố về hành vi
    seized_items: List[Dict[str, Any]] = field(default_factory=list)  # Tang chứng/vật chứng

    # Administrative-case specific (legacy-compatible)
    results: str = ""  # Kết quả giải quyết
    form_of_punishment: str = ""  # Hình thức xử phạt
    penalty_amount: float = 0.0
    note: str = ""  # Ghi chú

    evidence: List[str] = field(default_factory=list)