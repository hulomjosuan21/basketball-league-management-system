from flask import request
from firebase_admin import messaging

from src.utils.api_response import ApiResponse

class NotificationService:
    @staticmethod
    def send_fcm_notification_test():
        data = request.get_json()
        token = data.get('token')
        title = data.get('title', 'No Title')
        body = data.get('body', 'No Body')

        if not token:
            raise ValueError('Missing FCM token')

        try:
            message = messaging.Message(
                notification=messaging.Notification(title=title, body=body),
                token=token
            )
            response = messaging.send(message)
            return ApiResponse.success(payload=response)
        except Exception as e:
            return ApiResponse.error(str(e))
        
    @staticmethod
    def send_fcm_notification(token, title, body = "No Body"):
        if not token:
            raise ValueError('Missing FCM token')
        
        if not title:
            raise ValueError('Missing title')

        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title="Team Invitation",
                    body=body
                ),
                token=token
            )
            messaging.send(message)

        except Exception as e:
            raise