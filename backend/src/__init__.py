from flask import Flask
from flask_cors import CORS
from src.config import Config
from src.extensions import db, migrate, jwt, limiter
import os

from src.routes.administrator.administrator_route import administrator_bp
from src.routes.test_route import test_bp
from src.routes.place_route import place_route
from src.routes.file_routes import FileRoutes

from src.models.player_model import *
from src.models.user_model import *

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

    def init_blueprints(self):
        @self.server.get("/")
        def hello():
            return "Programmer: Josuan Leonardo Hulom BSIT 3B"
    
        self.server.register_blueprint(administrator_bp)
        # self.server.register_blueprint(test_bp)
        self.server.register_blueprint(place_route)
        file_routes = FileRoutes(self.server)
        self.server.register_blueprint(file_routes.get_blueprint())
        print(f"APP URL MAP: {self.server.url_map}")
    
    def init_server(self):

        self.init_extensions()
        self.init_blueprints()

        with self.server.app_context():
            db.create_all()

        return self.server