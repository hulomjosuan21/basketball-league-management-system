from flask import Flask
from flask_cors import CORS
from src.workers.test import job_wrapper
from src.config import Config
from src.controllers.organization_type import organization_type_list
from src.controllers.barangay_list import barangay_list
from src.extensions import db, migrate, jwt, limiter, socketio, scheduler
import os
import atexit
from functools import partial
from apscheduler.triggers.interval import IntervalTrigger
from src.routes.test_route import test_bp
from src.routes.user.user_route import user_bp
from src.routes.notification_routes import notification_bp
from src.routes.file_routes import FileRoutes
from src.routes.player.player_route import player_bp
from src.routes.team_creator.team_creator_route import team_creator_bp 
from src.routes.league.league_routes import league_bp
from src.routes.entity_routes import entity_bp
from src.routes.team.team_routes import team_bp
from src.routes.payment_routes import payment_bp
from src.models.player_model import *
from src.models.user_model import *
from src.models.league_administrator_model import *
from src.models.league_model import *
from src.models.team_model import *
from src.models.audit_log_model import *
from src.models.payment_model import *
from src.models.notification_model import *

BASE_DIR = os.path.abspath(os.path.dirname(__file__))

class FlaskServer:
    def __init__(self):
        self.server = Flask(
            __name__,
            static_url_path='/uploads',
            static_folder=os.path.join(BASE_DIR, 'uploads')
        )
        self.configure()

    def _init_scheduler(self):
        if not scheduler.running:
            scheduler.add_job(
                partial(job_wrapper, self.server),
                'interval',
                seconds=5
            )
            
            @self.server.before_request
            def start_scheduler():
                if not scheduler.running:
                    scheduler.start()
                    atexit.register(scheduler.shutdown)


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
        
        self.server.get("/organization-types")(organization_type_list)
        self.server.get("/barangay-list")(barangay_list)

        self.server.get('/log/<string:audit_id>')(AuditLogModel.fetch_log)
        self.server.get('/logs/<string:audit_to_id>')(AuditLogModel.fetch_logs_for)
        
        self.server.register_blueprint(player_bp)
        self.server.register_blueprint(team_creator_bp)
        self.server.register_blueprint(payment_bp)
        self.server.register_blueprint(entity_bp)
        self.server.register_blueprint(notification_bp)

        self.server.register_blueprint(league_bp)
        self.server.register_blueprint(team_bp)
        self.server.register_blueprint(user_bp)
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