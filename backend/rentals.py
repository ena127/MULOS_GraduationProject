from flask import Blueprint, jsonify, request
from flask_restful import Resource, Api
from database import get_db_connection
from datetime import datetime


# Blueprint 생성
rentals_bp = Blueprint('rentals', __name__)
api = Api(rentals_bp)  # Blueprint에 Api 객체 연결

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
                # 대여 정보 구성
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

            # 전체 대여 정보 조회
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

# 대여 기록 추가 (POST /rentals)
#@app.route('/rentals', methods=['POST'])
    def post(self):
        data = request.json 

        # 데이터 유효성 검사 : student_id가 None이면 error code 400
        if not data or 'student_id' not in data:
            return {'error': 'Missing required fields'}, 400 
        

        user_id = data.get('user_id')
        device_id = data.get('device_id')

        # 날짜 문자열을 datetime 형식으로 변환
        request_date = datetime.strptime(data.get('request_date'), '%Y-%m-%dT%H:%M:%S')
        status = data.get('status')
        approval_date = datetime.strptime(data.get('approval_date'), '%Y-%m-%dT%H:%M:%S') if data.get('approval_date') else None
        end_date = datetime.strptime(data.get('end_date'), '%Y-%m-%dT%H:%M:%S') if data.get('end_date') else None


        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO rental (user_id, device_id, request_date, status, approval_date, end_date) VALUES (%s, %s, %s, %s, %s, %s)',
            (user_id, device_id, request_date, status, approval_date, end_date)
        )
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({'message': '대여 기록이 추가되었습니다!'}), 201
    

# 엔드포인트 설정
api.add_resource(Rentals, '', '/<int:user_id>')