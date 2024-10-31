from flask import Blueprint, jsonify, request
from flask_restful import Resource, Api
from database import get_db_connection
from datetime import datetime


# Blueprint 생성
returns_bp = Blueprint('returns', __name__)
api = Api(returns_bp)  # Blueprint에 Api 객체 연결

class Returns(Resource):
    # 10.31 get method 추가
   def get(self, user_id=None):
        conn = get_db_connection()
        cursor = conn.cursor()

        try:
            # 특정 사용자의 반납 정보 조회
            if user_id:
                cursor.execute('''
                    SELECT rd.return_id, rd.rental_id, rd.return_date, rd.photo_url, rd.status, rd.condition
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
                        'condition': ret[5]
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
                        'condition': ret[5]
                    } for ret in returns
                ]
                return jsonify(returns_list)
        finally:
            cursor.close()
            conn.close()

   def post(self):
        # 10.31 코드에 rental_id 없던것 수정
        data = request.json
        # 데이터 유효성 검사
        if not data or 'rental_id' not in data:
            return jsonify({'error': 'Missing required fields'}), 400
        
        data = request.json
        rental_id = data.get('rental_id')
        return_date = datetime.strptime(data.get('return_date'), '%Y-%m-%dT%H:%M:%S')
        photo_url = data.get('photo_url')
        status = data.get('status')
        condition = data.get('condition')

        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute(
            'INSERT INTO return_device (rental_id, return_date, photo_url, status, condition) VALUES (%s, %s, %s, %s, %s)',
            (rental_id, return_date, photo_url, status, condition)
        )
        conn.commit()
        cursor.close()
        conn.close()

        return {'message': '반납 기록이 추가되었습니다!'}, 201

# 엔드포인트 설정
api.add_resource(Returns, '', '/<int:user_id>')