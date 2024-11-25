from flask import Blueprint, jsonify, request
from flask_restful import Resource, Api
from .database import get_db_connection
from datetime import datetime

# Blueprint 생성
rentals_bp = Blueprint('rentals', __name__)
api = Api(rentals_bp)

class Rentals(Resource):
    def get(self, user_id=None):
        conn = get_db_connection()
        cursor = conn.cursor()
        try:
            # 특정 사용자의 대여 정보 조회
            if user_id:
                cursor.execute('SELECT * FROM rental WHERE user_id = %s', (user_id,))
                rentals = cursor.fetchall()
                if not rentals:
                    return {"message": "No rentals found for this user"}, 404
                rentals_list = [
                    {
                        'rental_id': rental[0],
                        'user_id': rental[1],
                        'device_id': rental[2],
                        'request_date': rental[3],
                        'status': rental[4],
                        'approval_date': rental[5],
                        'end_date': rental[6]
                    } for rental in rentals
                ]
                return jsonify(rentals_list)
            else:
                cursor.execute('SELECT * FROM rental')
                rentals = cursor.fetchall()
                rentals_list = [
                    {
                        'rental_id': rental[0],
                        'user_id': rental[1],
                        'device_id': rental[2],
                        'request_date': rental[3],
                        'status': rental[4],
                        'approval_date': rental[5],
                        'end_date': rental[6]
                    } for rental in rentals
                ]
                return jsonify(rentals_list)
        finally:
            cursor.close()
            conn.close()

    def post(self):
        data = request.json

        # 필수 데이터 확인
        if not data or 'student_id' not in data or 'device_name' not in data:
            return {'error': 'Missing required fields'}, 400

        student_id = data.get('student_id')
        device_name = data.get('device_name')
        request_date = data.get('request_date', datetime.now().isoformat())
        status = data.get('status', 'stand by')  # 기본값 설정

        conn = get_db_connection()
        cursor = conn.cursor()

        try:
            # `student_id`로 `user_id` 조회
            cursor.execute('SELECT user_id FROM user WHERE student_id = %s', (student_id,))
            user = cursor.fetchone()
            if not user:
                return {'error': 'User not found'}, 404
            user_id = user[0]

            # `device_name`으로 `device_id` 조회
            cursor.execute('SELECT device_id FROM device WHERE device_name = %s AND availability = 1', (device_name,))
            device = cursor.fetchone()
            if not device:
                return {'error': 'Device not available or not found'}, 404
            device_id = device[0]

            # 날짜 문자열 유효성 검사 및 변환
            try:
                request_date_parsed = datetime.fromisoformat(request_date)
            except ValueError:
                return {'error': 'Invalid request_date format. Use ISO8601.'}, 400

            # 대여 기록 추가
            cursor.execute(
                'INSERT INTO rental (user_id, device_id, request_date, status) VALUES (%s, %s, %s, %s)',
                (user_id, device_id, request_date_parsed, status)
            )

            # 기기 상태 업데이트
            cursor.execute('UPDATE device SET availability = 0 WHERE device_id = %s', (device_id,))

            conn.commit()
            return {'message': '대여 기록이 추가되었습니다!'}, 201
        except Exception as e:
            conn.rollback()
            return {'error': str(e)}, 500
        finally:
            cursor.close()
            conn.close()


api.add_resource(Rentals, '', '/<int:user_id>')