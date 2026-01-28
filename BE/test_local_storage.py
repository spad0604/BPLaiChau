import os
import io
from app.services.local_storage_service import upload_file

def test_upload():
    # Create dummy file
    content = b"Hello world"
    f = io.BytesIO(content)
    f.name = "test.txt"
    
    # Test upload
    url = upload_file(f, folder="test_folder")
    print(f"Uploaded URL: {url}")
    
    # Verify file exists
    if url:
        path = url.lstrip("/")
        # Fix path separator for windows check if needed, but python open handles it
        # url is /static/uploads/test_folder/...
        # path is static/uploads/test_folder/...
        if os.path.exists(path):
            print("File exists on disk.")
            # clean up
            os.remove(path)
            os.rmdir(os.path.dirname(path))
            print("Cleaned up.")
        else:
            print(f"File NOT found at {path}")
    else:
        print("Upload failed.")

if __name__ == "__main__":
    test_upload()
