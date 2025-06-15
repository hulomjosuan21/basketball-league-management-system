from datetime import timedelta
from flask_jwt_extended import create_access_token
from src.services.email_services import send_verification_email
from src.errors.errors import AuthException
from src.utils.file_utils import save_file
from src.models.player_model import PlayerModel
from src.utils.api_response import ApiResponse
from src.extensions import db
from flask import request, jsonify, render_template_string
from src.models.user_model import AccountTypeEnum, UserModel

class PlayerAuthControllers:
    async def create_player(self):
        try:
            email = request.form.get('user[email]')
            password_str = request.form.get('user[password_str]')
            account_type = request.form.get('user[account_type]')
            contact_number = request.form.get('user[contact_number]')

            if not all([email, password_str, account_type, contact_number]):
                raise ValueError("All fields must be provided and not empty.")
            user = UserModel(
                email=email,
                contact_number=contact_number,
                account_type=account_type
            )
            user.set_password(password_str)

            first_name = request.form.get('first_name')
            last_name = request.form.get('last_name')
            gender = request.form.get('gender')
            birth_date = request.form.get('birth_date')

            barangay_name = request.form.get('barangay_name')
            municipality_name = request.form.get('municipality_name')

            jersey_name = request.form.get('jersey_name')
            jersey_number = request.form.get('jersey_number')
            position = request.form.get('position')

            height_in = request.form.get('height_in')
            weight_kg = request.form.get('weight_kg')

            profile_image_file = request.files.get('profile_image_file')

            if not all([first_name, last_name, gender, birth_date, jersey_name, jersey_number, position, profile_image_file, barangay_name, municipality_name]):
                raise ValueError("All fields must be provided and not empty.")

            full_url = await save_file(profile_image_file, 'profiles', request, 'supabase')
            player = PlayerModel(
                first_name=first_name,
                last_name=last_name,
                gender=gender,
                birth_date=birth_date,
                barangay_name=barangay_name,
                municipality_name=municipality_name,
                jersey_name=jersey_name,
                jersey_number=jersey_number,
                position=position,
                height_in=float(height_in) if height_in else None,
                weight_kg=float(weight_kg) if weight_kg else None,
                profile_image_url=full_url,
                user=user
            )
            db.session.add(user)
            db.session.add(player)
            db.session.commit()

            verify_link = f"/user/{user.user_id}"

            await send_verification_email(email, verify_link, request)
            
            return ApiResponse.success(message="Verification link sent to email.",status_code=201)
        except Exception as e:
            db.session.rollback()
            return ApiResponse.error(e)