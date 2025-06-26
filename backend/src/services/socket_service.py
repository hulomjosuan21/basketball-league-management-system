from flask import request
from enum import Enum
from src.utils.api_response import ApiResponse
from src.extensions import socketio

class SocketEvent(str, Enum):
    CONNECT = 'connect'
    DISCONNECT = 'disconnect'
    REGISTER = 'register'
    ECHO = 'echo'
    ECHO_RESPONSE = 'echo_response'
    NOTIFICATION = 'notification'


class SocketService:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance.connected_users = {}
            cls._instance._register_events()
        return cls._instance

    def _register_events(self):
        @socketio.on(SocketEvent.CONNECT.value)
        def on_connect():
            print(f"[SocketIO] 🔌 Connected: {request.sid}")

        @socketio.on(SocketEvent.DISCONNECT.value)
        def on_disconnect():
            for uid, sid in list(self.connected_users.items()):
                if sid == request.sid:
                    del self.connected_users[uid]
                    print(f"[SocketIO] ❌ Disconnected: {uid}")
                    break

        @socketio.on(SocketEvent.REGISTER.value)
        def on_register(data):
            user_id = data.get("user_id")
            if user_id:
                self.connected_users[user_id] = request.sid
                print(f"[SocketIO] ✅ Registered {user_id} with SID {request.sid}")

        @socketio.on(SocketEvent.ECHO.value)
        def on_echo(data):
            socketio.emit(SocketEvent.ECHO_RESPONSE.value, {"message": data.get("message", "")}, to=request.sid)

    def emit_to_user(self, user_id: str, event: SocketEvent, payload: dict) -> ApiResponse:
        sid = self.connected_users.get(user_id)
        if not sid:
            return ApiResponse.error("User not connected")

        socketio.emit(event.value, payload, to=sid)
        print(f"[SocketIO] 📤 Sent event '{event.value}' to {user_id}")
        return ApiResponse.success()

    def broadcast(self, event: SocketEvent, data: dict) -> ApiResponse:
        try:
            socketio.emit(event.value, data)
            print(f"[SocketIO] 📢 Broadcasted {event.value}")
            return ApiResponse.success()
        except Exception as e:
            print(f"[SocketIO] Broadcast error: {e}")
            return ApiResponse.error(str(e))

socket_service = SocketService()