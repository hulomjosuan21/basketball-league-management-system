from src.models.user_model import UserModel
from src.services.notification_serices import NotificationService
from src.utils.api_response import ApiResponse
from src.extensions import socketio
from flask import request
from firebase_admin import messaging

class SocketController:
    def __init__(self):
        self.connected_users = {}
        self._register_events()

    def _register_events(self):
        @socketio.on('connect')
        def on_connect():
            print(f"[SocketIO] 🔌 Client connected: {request.sid}")

        @socketio.on('disconnect')
        def on_disconnect():
            print(f"[SocketIO] 🔌 Client disconnected: {request.sid}")
            disconnected_user = None
            for uid, sid in list(self.connected_users.items()):
                if sid == request.sid:
                    disconnected_user = uid
                    del self.connected_users[uid]
                    break
            if disconnected_user:
                print(f"[SocketIO] User {disconnected_user} removed from connected_users")


        @socketio.on('register')
        def on_register(data):
            user_id = data.get('user_id')
            if user_id:
                self.connected_users[user_id] = request.sid
                print(f"[SocketIO] Registered user {user_id} with sid {request.sid}")

        @socketio.on('echo')
        def on_echo(data):
            socketio.emit('echo_response', {'message': data.get('message', '')}, to=request.sid)

    def send(self, user_id):
        try:
            json_data = request.get_json(force=True) or {}
            event = json_data.get('event')
            payload = json_data.get('payload')
            sid = self.connected_users.get(user_id)

            if not event or not payload:
                raise ValueError('Mising data')

            if sid and sid in socketio.server.manager.rooms['/']:
                user = UserModel.query.get(user_id)
                fcm_token = user.fcm_token
                message = messaging.Message(
                    notification=messaging.Notification(title=event, body=payload['detail']),
                    token=fcm_token
                )

                messaging.send(message)

                socketio.emit(event, payload, to=sid)
                print(f"[SocketIO] Sent event '{event}' to user {user_id}")
                return ApiResponse.success()

            print(f"[SocketIO] User {user_id} not connected or sid is invalid")
            return ApiResponse.error(message="User not connected")
        
        except Exception as e:
            print(f"[SocketIO] Error while sending to user {user_id}: {e}")
            return ApiResponse.error(str(e))
        
    def broadcast(self, event, data):
        socketio.emit(event, data)
        