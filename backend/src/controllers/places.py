import json
import os

from src.utils.api_response import ApiResponse

def getCityAndBarangays():
    try:
        current_dir = os.path.dirname(os.path.abspath(__file__))
        json_path = os.path.join(current_dir, '..', '..', 'assets', 'LGU_barangays.json')

        with open(json_path, 'r') as file:
            city_barangay_data = json.load(file)

        cities = list(city_barangay_data.keys())
        barangays = city_barangay_data

        payload = {
            "municipalities": cities,
            "barangays": barangays
        }

        return ApiResponse.success(payload=payload);
    except Exception as e:
        return ApiResponse.error(e)