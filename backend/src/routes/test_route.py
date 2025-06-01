from flask import Blueprint, jsonify, request
from src.models.test_model import TestModel
from src.extensions import db
test_bp = Blueprint('test', __name__, url_prefix='/test')
from src.utils.api_response import ApiResponse

@test_bp.post('')
def add_test():
    try:
        data = request.get_json()
        if not data or 'content' not in data:
            return ApiResponse.error("Invalid input", 400)

        content = data.get('content')
        if not content: 
            return ApiResponse.error("Content cannot be empty", 400)
        if content == "Hulom":
            return ApiResponse.error("Content cannot be Hulom", 401)
        
        new_test = TestModel(content=content)
        db.session.add(new_test)
        db.session.commit()

        tests = TestModel.query.all()
        test_list = [{"id": test.id, "content": test.content} for test in tests]

        return ApiResponse.success(message="Test added successfully", payload=test_list, status_code=201)

    except Exception as e:
        db.session.rollback()
        return ApiResponse.error(e)


@test_bp.get('')
def list_tests():
    try:
        tests = TestModel.query.all()
        test_list = [{"id": test.id, "content": test.content} for test in tests]
        
        return ApiResponse.success(payload=test_list,status_code=200)
    except Exception as e:
        db.session.rollback()
        return ApiResponse.error(e)