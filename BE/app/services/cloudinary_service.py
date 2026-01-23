import os
from typing import IO, Optional
import cloudinary
import cloudinary.uploader


def configure_from_env():
    # cloudinary will also read CLOUDINARY_URL if set
    cloud_name = os.getenv("CLOUDINARY_CLOUD_NAME")
    api_key = os.getenv("CLOUDINARY_API_KEY")
    api_secret = os.getenv("CLOUDINARY_API_SECRET")
    if cloud_name and api_key and api_secret:
        cloudinary.config(cloud_name=cloud_name, api_key=api_key, api_secret=api_secret)


def upload_file(file_obj: IO, folder: Optional[str] = None) -> Optional[str]:
    """Upload a file-like object to Cloudinary and return secure_url, or None on failure."""
    try:
        configure_from_env()
        params = {"resource_type": "auto"}
        if folder:
            params["folder"] = folder
        res = cloudinary.uploader.upload(file_obj, **params)
        return res.get("secure_url")
    except Exception:
        return None
