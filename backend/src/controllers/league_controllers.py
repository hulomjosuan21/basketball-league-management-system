from flask import request

class LeagueControllers:
    async def create_league():
        password_str = request.form.get('user[password_str]')