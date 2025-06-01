from flask import jsonify, make_response
from sqlalchemy.exc import IntegrityError, DataError, OperationalError

class ApiResponse:
    @staticmethod
    def success(message="Success", payload=None, status_code=200):
        response = {
            "status": True,
            "message": message,
        }
        if payload is not None:
            response["payload"] = payload
        return make_response(jsonify(response), status_code)

    @staticmethod
    def error(error="An error occurred", status_code=None):
        message = "An error occurred"
        code = 500

        if isinstance(error, Exception):
            if isinstance(error, IntegrityError):
                message = "Duplicate entry or constraint violation"
                code = 409
            elif isinstance(error, DataError):
                message = "Invalid data format or length"
                code = 400
            elif isinstance(error, OperationalError):
                message = "Database operational error"
                code = 503
            else:
                message = str(error) or message
        else:
            message = error

        if status_code is not None:
            code = status_code

        response = {
            "status": False,
            "message": message
        }
        return make_response(jsonify(response), code)
