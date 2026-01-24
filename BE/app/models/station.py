from dataclasses import dataclass


@dataclass
class Station:
    """Border guard station (Đồn Biên Phòng)."""

    station_id: str = ""
    name: str = ""
    code: str = ""  # optional short code
    address: str = ""
    phone: str = ""
    created_at: str = ""
