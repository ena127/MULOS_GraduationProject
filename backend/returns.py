from flask import Blueprint, jsonify, request
from flask_restful import Resource, Api
from database import get_db_connection
from datetime import datetime


# Blueprint 생성
returns_bp = Blueprint('returns', __name__)
api = Api(returns_bp)  # Blueprint에 Api 객체 연결

class Returns(Resource):
# 반납 기록 추가 (POST /returns)
# @app.route('/returns', methods=['POST'])
    def post(self):
        data = request.json
        rental_id = data.get('rental_id')
        return_date = datetime.strptime(data.get('return_date'), '%Y-%m-%dT%H:%M:%S')
        photo_url = data.get('photo_url')
        status = data.get('status')
        condition = data.get('condition')

        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO return (rental_id, return_date, photo_url, status, condition) VALUES (%s, %s, %s, %s, %s)',
            (rental_id, return_date, photo_url, status, condition)
        )
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({'message': '반납 기록이 추가되었습니다!'}), 201

api.add_resource(Returns, '')