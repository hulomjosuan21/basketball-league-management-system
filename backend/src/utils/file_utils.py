import os
from urllib.parse import urlparse
import uuid
from werkzeug.utils import secure_filename
from flask import current_app
from werkzeug.datastructures import FileStorage

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'pdf', 'docx', 'txt', 'ico'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def save_file(file: FileStorage, subfolder: str, request) -> str:
    if file and allowed_file(file.filename):
        original_filename = secure_filename(file.filename)
        extension = os.path.splitext(original_filename)[1]
        unique_filename = f"{uuid.uuid4().hex}{extension}"

        upload_folder = os.path.join(current_app.config['UPLOAD_FOLDER'], subfolder)
        os.makedirs(upload_folder, exist_ok=True)

        file_path = os.path.join(upload_folder, unique_filename)
        file.save(file_path)

        file_url = f"/uploads/{subfolder}/{unique_filename}"
        full_url = request.host_url.rstrip('/') + file_url
        return full_url
    else:
        raise ValueError("Invalid file or unsupported file type.")

def delete_file_by_url(file_url: str) -> bool:
    try:
        parsed_url = urlparse(file_url)
        file_path = parsed_url.path 

        prefix = '/uploads/'
        if not file_path.startswith(prefix):
            return False

        relative_path = file_path[len(prefix):]

        parts = relative_path.split('/')
        if len(parts) < 2:
            return False

        subfolder = parts[0]
        filename = secure_filename(parts[-1])

        safe_path = os.path.join(subfolder, filename)

        full_path = os.path.join(current_app.config['UPLOAD_FOLDER'], safe_path)

        if os.path.exists(full_path):
            os.remove(full_path)
            return True

        return False
    except Exception as e:
        print(f"Error deleting file by URL: {e}")
        return False