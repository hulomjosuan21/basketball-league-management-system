from src.utils.db_utils import AccountTypeEnum
from src.models.user_model import UserModel
from src.utils.api_response import ApiResponse
from src.extensions import socketio
from enum import Enum
from flask import request
from firebase_admin import messaging


class SocketEvent(str, Enum):
    CONNECT = 'connect'
    CONNECT_ERROR = 'connect_error'
    ERROR = 'error'
    DISCONNECT = 'disconnect'
    REGISTER = 'register'
    ECHO = 'echo'
    ECHO_RESPONSE = 'echo_response'
    PRIVATE_MESSAGE = 'private_message'
    NOTIFICATION = 'notification'


class SocketController:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(SocketController, cls).__new__(cls)
            cls._instance.connected_users = {}
            cls._instance._register_events()
        return cls._instance

    def _register_events(self):
        @socketio.on(SocketEvent.CONNECT.value)
        def on_connect():
            print(f"[SocketIO] 🔌 Client connected: {request.sid}")

        @socketio.on(SocketEvent.DISCONNECT.value)
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

        @socketio.on(SocketEvent.REGISTER.value)
        def on_register(data):
            user_id = data.get('user_id')
            if user_id:
                self.connected_users[user_id] = request.sid
                print(f"[SocketIO] Registered user {user_id} with sid {request.sid}")

        @socketio.on(SocketEvent.ECHO.value)
        def on_echo(data):
            socketio.emit(SocketEvent.ECHO_RESPONSE.value, {
                'message': data.get('message', '')
            }, to=request.sid)

    def send(self, user_id, event: SocketEvent):
        try:
            json_data = request.get_json(force=True) or {}
            payload = json_data.get('payload')
            sid = self.connected_users.get(user_id)

            if not event or not payload:
                raise ValueError('Missing event or payload')

            user = UserModel.query.get(user_id)
            if not user:
                raise ValueError('User not found')

            # Send push notification
            fcm_token = user.fcm_token
            if fcm_token:
                message = messaging.Message(
                    notification=messaging.Notification(
                        title=event.value.replace("_", " ").title(),
                        body=payload.get('detail', '')
                    ),
                    token=fcm_token
                )
                messaging.send(message)

            # Send socket event if connected
            if sid:
                socketio.emit(event.value, payload, to=sid)
                print(f"[SocketIO] Sent event '{event.value}' to user {user_id}")
                return ApiResponse.success()

            print(f"[SocketIO] User {user_id} not connected or sid is invalid")
            return ApiResponse.error("User not connected")

        except Exception as e:
            print(f"[SocketIO] Error while sending to user {user_id}: {e}")
            return ApiResponse.error(str(e))

    def send_player_invitation_notification(self, user_id, team, enable_fcm = False):
        try:
            sid = self.connected_users.get(user_id)
            event = SocketEvent.NOTIFICATION

            payload = team.to_json_for_notification(
                f"You have been invited to join the team \"{team.team_name}\".")
            payload['account_type'] = AccountTypeEnum.TEAM_CREATOR.value
            if sid:
                socketio.emit(event.value, payload, to=sid)
                print(f"[SocketIO] Sent event '{event.value}' to user {user_id}")

                if enable_fcm:
                    user = UserModel.query.get(user_id)
                    if not user:
                        raise ValueError(f'User with the id of {user_id} not found.')

                    if user.fcm_token:
                        message = messaging.Message(
                            notification=messaging.Notification(
                                title=f"From: {team.team_name}",
                                body=payload['detail']
                            ),
                            token=user.fcm_token
                        )
                        messaging.send(message)
                print(f"[SocketIO] Sent invitation notification to user {user_id}")
                return ApiResponse.success()

            print(f"[SocketIO] User {user_id} not connected or sid is invalid")
            return ApiResponse.error("User not connected")

        except Exception as e:
            print(f"[SocketIO] Error while sending player invitation to user {user_id}: {e}")
            return ApiResponse.error(str(e))

    def broadcast(self, event: SocketEvent, data):
        try:
            socketio.emit(event.value, data)
            print(f"[SocketIO] Broadcasted event '{event.value}' with data: {data}")
            return ApiResponse.success()
        except Exception as e:
            print(f"[SocketIO] Error broadcasting event '{event.value}': {e}")
            return ApiResponse.error(str(e))

socket_controller = SocketController()
