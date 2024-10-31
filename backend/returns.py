from flask import Blueprint, jsonify, request
from flask_restful import Resource, Api
from database import get_db_connection
from datetime import datetime


# Blueprint 생성
returns_bp = Blueprint('returns', __name__)
api = Api(returns_bp)  # Blueprint에 Api 객체 연결

from flask import jsonify, request
from flask_restful import Resource
from database import get_db_connection
from datetime import datetime

class Returns(Resource):

    # 10.31 get method 추가
    def get(self, user_id=None):
        conn = get_db_connection()
        cursor = conn.cursor()

        try:
            # 특정 사용자의 반납 정보 조회
            if user_id:
                cursor.execute('''
                    SELECT rd.return_id, rd.rental_id, rd.return_date, rd.photo_url, rd.status, rd.conditions
                    FROM return_device rd
                    JOIN rental r ON rd.rental_id = r.rental_id
                    WHERE r.user_id = %s
                ''', (user_id,))

                returns = cursor.fetchall()

                if not returns:
                    return {"message": "No returns found for this user"}, 404
                # 반납 정보 구성
                returns_list = [
                    {
                        'return_id': ret[0],
                        'rental_id': ret[1],
                        'return_date': ret[2],
                        'photo_url': ret[3],
                        'status': ret[4],
                        'conditions': ret[5]
                    } for ret in returns
                ]
                return jsonify(returns_list)

            # 전체 반납 정보 조회
            else:
                cursor.execute('SELECT * FROM return_device')
                returns = cursor.fetchall()
                returns_list = [
                    {
                        'return_id': ret[0],
                        'rental_id': ret[1],
                        'return_date': ret[2],
                        'photo_url': ret[3],
                        'status': ret[4],
                        'conditions': ret[5]
                    } for ret in returns
                ]
                return jsonify(returns_list)
        finally:
            cursor.close()
            conn.close()

    def post(self):
        data = request.json
        
        # 데이터 유효성 검사
        if not data or 'rental_id' not in data:
            return {'error': 'Missing required fields'}, 400
        
        rental_id = data.get('rental_id')
        return_date = datetime.strptime(data.get('return_date'), '%Y-%m-%dT%H:%M:%S')
        photo_url = data.get('photo_url')
        status = data.get('status')
        conditions = data.get('conditions')  # 필드명 변경

        # DB 연결
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute('SELECT rental_id FROM rental WHERE rental_id = %s', (rental_id,))
        if cursor.fetchone() is None:
            return {'error': 'Invalid rental_id: no such rental record'}, 400

        try:
            # 반납 기록 추가
            cursor.execute(
                'INSERT INTO return_device (rental_id, return_date, photo_url, status, conditions) VALUES (%s, %s, %s, %s, %s)',
                (rental_id, return_date, photo_url, status, conditions)
            )

            # rental_id로 device_id 조회
            cursor.execute('SELECT device_id FROM rental WHERE rental_id = %s', (rental_id,))
            device = cursor.fetchone()
            
            if not device:
                return {'error': 'Device not found for this rental ID'}, 404
            
            device_id = device[0]

            # 기기의 availability 상태를 "available"로 업데이트
            cursor.execute('UPDATE device SET availability = %s WHERE device_id = %s', ("available", device_id))
            conn.commit()

            return {'message': '반납 기록이 추가되고 기기의 상태가 변경되었습니다!'}, 201

        except Exception as e:
            conn.rollback()
            print(f"Error: {e}")
            return {'error': 'Failed to process the return'}, 500

        finally:
            cursor.close()
            conn.close()

# 엔드포인트 설정
api.add_resource(Returns, '', '/<int:user_id>')