from flask import Blueprint, jsonify,request
from src.extensions import PlaceLoader

place_route = Blueprint('place_route', __name__,url_prefix='/places')

@place_route.get('/barangays/<string:city>')
def get_barangays(city: str):
    try:
        if not city:
            return jsonify([]), 200

        place = PlaceLoader(city_key=city)
        place.load()

        return jsonify(place.get_barangays()), 200
    except Exception as e:
        return jsonify([]), 200
