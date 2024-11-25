from flask import Blueprint, jsonify
from flask_restful import Resource, Api
from .database import get_db_connection

professors_bp = Blueprint('professors', __name__)
api = Api(professors_bp)

class Professors(Resource):
    def get(self):
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT name FROM professors')  # 'name' 컬럼에 교수님 이름 저장
        professors = [row[0] for row in cursor.fetchall()]
        cursor.close()
        conn.close()
        return jsonify(professors)

api.add_resource(Professors, '')