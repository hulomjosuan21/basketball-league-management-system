from flask_jwt_extended import JWTManager
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_migrate import Migrate
from flask_bcrypt import Bcrypt
from flask_sqlalchemy import SQLAlchemy
from argon2 import PasswordHasher
import json
import os
from flask_socketio import SocketIO
from flask import current_app
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["1000 per hour", "5000 per day"],
    headers_enabled=True
)
db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()
socketio = SocketIO(cors_allowed_origins="*")

ph = PasswordHasher()

def supabase_client() -> Client:
    supabase_url = current_app.config.get('SUPABASE_URL')
    supabase_key = current_app.config.get('SUPABASE_KEY')
    if not supabase_url or not supabase_key:
        raise ValueError("Supabase URL and Key must be configured in app settings.")
    return create_client(supabase_url, supabase_key)

class PlaceLoader:
    def __init__(self, json_path='../assets/LGU_barangays.json', city_key='City'):
        base_dir = os.path.dirname(os.path.abspath(__file__))
        self.json_path = os.path.join(base_dir, json_path)
        self.city_key = city_key
        self.barangays = []

    def load(self):
        try:
            with open(self.json_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            self.barangays = data.get(self.city_key, [])
        except FileNotFoundError:
            print(f"Error: JSON file not found at {self.json_path}")
            self.barangays = []
        except json.JSONDecodeError:
            print(f"Error: JSON file at {self.json_path} is not valid JSON.")
            self.barangays = []

    def get_barangays(self):
        return self.barangays

    def print_barangays(self):
        if not self.barangays:
            print("No barangays loaded.")
        else:
            for b in self.barangays:
                print(b)