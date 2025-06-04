import json
import os

from src.utils.api_response import ApiResponse

def getOrganizationTypes():
    try:
        current_dir = os.path.dirname(os.path.abspath(__file__))
        json_path = os.path.join(current_dir, '..', '..', 'assets', 'organization_types.json')

        with open(json_path, 'r') as file:
            organization_types = json.load(file)

        payload = organization_types

        return ApiResponse.success(payload=payload)
    except Exception as e:
        return ApiResponse.error(e)