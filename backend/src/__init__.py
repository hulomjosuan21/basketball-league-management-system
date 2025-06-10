from flask import Flask
from flask_cors import CORS
from src.config import Config
from src.controllers.organization_type import getOrganizationTypes
from src.controllers.places import getCityAndBarangays
from src.extensions import db, migrate, jwt, limiter, socketio
import os

from src.routes.administrator.administrator_route import administrator_bp
from src.routes.test_route import test_bp
from src.routes.user.user_route import user_bp
from src.routes.file_routes import FileRoutes

from src.models.player_model import *
from src.models.user_model import *
from src.models.league_administrator_model import *
from src.models.league_model import *
from src.models.team_model import *

BASE_DIR = os.path.abspath(os.path.dirname(__file__))

class FlaskServer:
    def __init__(self):
        self.server = Flask(
            __name__,
            static_url_path='/uploads',
            static_folder=os.path.join(BASE_DIR, 'uploads')
        )
        self.configure()

    def configure(self):
        self.server.config.from_object(Config)

    def init_extensions(self):
        db.init_app(self.server)
        migrate.init_app(self.server, db)
        jwt.init_app(self.server)
        limiter.init_app(self.server)
        self.server.config['UPLOAD_FOLDER'] = os.path.join(BASE_DIR, 'uploads')
        CORS(self.server, origins=self.server.config['CORS_ORIGINS'], supports_credentials=self.server.config['CORS_SUPPORTS_CREDENTIALS'])
        socketio.init_app(self.server, cors_allowed_origins=self.server.config['CORS_ORIGINS'])

    def init_blueprints(self):
        self.server.get("/")(lambda: "Programmer: Josuan Leonardo Hulom")
        
        self.server.get("/places")(getCityAndBarangays)
        self.server.get("/organization-types")(getOrganizationTypes)
    
        self.server.register_blueprint(user_bp)
        self.server.register_blueprint(administrator_bp)
        self.server.register_blueprint(test_bp)
        file_routes = FileRoutes(self.server)
        self.server.register_blueprint(file_routes.get_blueprint())
        print(f"APP URL MAP: {self.server.url_map}")
    
    def init_server(self):

        self.init_extensions()
        self.init_blueprints()

        with self.server.app_context():
            db.create_all()

        return self.server