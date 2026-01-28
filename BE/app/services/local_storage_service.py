import os
import shutil
import uuid
from typing import IO, Optional
from datetime import datetime

# Base directory for static files
STATIC_DIR = "static"
UPLOADS_DIR = os.path.join(STATIC_DIR, "uploads")

# Ensure upload directory exists
os.makedirs(UPLOADS_DIR, exist_ok=True)

def upload_file(file_obj: IO, filename: str = None, folder: Optional[str] = None) -> Optional[str]:
    """
    Save a file-like object to local storage and return a relative URL.
    
    Args:
        file_obj: The file-like object to save.
        filename: Original filename to extract extension.
        folder: Optional subfolder within the uploads directory.
        
    Returns:
        The relative URL of the saved file (e.g., /static/uploads/...), or None on failure.
    """
    try:
        # Create a unique filename
        ext = ""
        if filename:
             _, ext = os.path.splitext(filename)
        elif hasattr(file_obj, "name") and file_obj.name:
            _, ext = os.path.splitext(file_obj.name)
        
        saved_filename = f"{uuid.uuid4().hex}{ext}"
        
        # Determine target directory
        target_dir = UPLOADS_DIR
        if folder:
            # Sanitize folder path to prevent directory traversal
            safe_folder = folder.strip("/").replace("..", "")
            target_dir = os.path.join(UPLOADS_DIR, safe_folder)
            os.makedirs(target_dir, exist_ok=True)
            
        file_path = os.path.join(target_dir, saved_filename)
        
        # Write file
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file_obj, buffer)
            
        # Return absolute URL
        # Construct path relative to static root
        relative_path = os.path.relpath(file_path, STATIC_DIR)
        # Ensure forward slashes for URL
        url_path = f"/static/{relative_path.replace(os.sep, '/')}"
        
        from app.core.config import settings
        full_url = f"{settings.BASE_URL.rstrip('/')}{url_path}"
        
        return full_url
        
    except Exception as e:
        print(f"Error uploading file: {e}")
        return None
