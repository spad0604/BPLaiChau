from dataclasses import dataclass, field

@dataclass
class BackgroundBanner:
    banner_id: str = ""
    image_url: str = ""
    banner_title: str = ""