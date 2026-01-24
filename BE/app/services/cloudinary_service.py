import os
from typing import IO, Optional
import cloudinary
import cloudinary.uploader


def configure_from_env():
    """Configure Cloudinary from environment.

    Preferred: set CLOUDINARY_URL=cloudinary://<api_key>:<api_secret>@<cloud_name>
    Fallback: set CLOUDINARY_CLOUD_NAME/CLOUDINARY_API_KEY/CLOUDINARY_API_SECRET.
    """

    # If CLOUDINARY_URL is set, the Cloudinary SDK can load it.
    if os.getenv("CLOUDINARY_URL"):
        cloudinary.config(secure=True)
        return

    cloud_name = os.getenv("CLOUDINARY_CLOUD_NAME")
    api_key = os.getenv("CLOUDINARY_API_KEY")
    api_secret = os.getenv("CLOUDINARY_API_SECRET")
    if cloud_name and api_key and api_secret:
        cloudinary.config(cloud_name=cloud_name, api_key=api_key, api_secret=api_secret, secure=True)


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
