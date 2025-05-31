from flask import Blueprint, jsonify, request
from src.models.test_model import TestModel
from src.extensions import db
test_bp = Blueprint('test', __name__, url_prefix='/test')

@test_bp.post('')
def add_test():
    data = request.get_json()
    if not data or 'content' not in data:
        return jsonify({"error": "Invalid input"}), 400
    content = data.get('content')

    if not content:
        return jsonify({"error": "Content cannot be empty"}), 400
    
    new_test = TestModel(content=content)
    db.session.add(new_test)
    db.session.commit()

    tests = TestModel.query.all()
    test_list = [{"id": test.id, "content": test.content} for test in tests]

    return jsonify(test_list), 201

@test_bp.get('')
def list_tests():
    tests = TestModel.query.all()
    test_list = [{"id": test.id, "content": test.content} for test in tests]
    
    return jsonify(test_list), 200