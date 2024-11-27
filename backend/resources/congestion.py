from flask import Blueprint, jsonify, request
from flask_restful import Resource, Api
from .database import get_db_connection

# Blueprint 생성
congestion_bp = Blueprint('congestion', __name__)
api = Api(congestion_bp)  # Blueprint에 Api 객체 연결

# 사람 수와 혼잡도를 데이터베이스에 저장하는 엔드포인트 (POST /congestion)
class Congestion(Resource):
    def post(self):
        data = request.json
        print(f"[DEBUG] POST /congestion received data: {data}")  # POST 요청 로그

        person_count = data.get('person_count', 0)  # 기본값을 0으로 설정
        congestion_ratio = data.get('congestion_ratio', None)

        # 혼잡도 상태를 결정
        if congestion_ratio is not None:sudo vi /home/<username>/.ssh/authorized_keys

            if congestion_ratio <= 0.333:
                congestion_status = '쾌적'
            elif congestion_ratio > 0.666:
                congestion_status = '혼잡'
            else:
                congestion_status = '보통'
        else:
            congestion_status = None

        # 데이터베이스 연결 및 삽입
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.execute(
                "INSERT INTO congestion (person_num, congestion_ratio, congestion_level) VALUES (%s, %s, %s)",
                (person_count, congestion_ratio, congestion_status)
            )
            conn.commit()
            print(f"Data inserted: {person_count}, {congestion_ratio}, {congestion_status}")
        except Exception as e:
            print(f"Error inserting data: {e}")
        finally:
            cursor.close()
            conn.close()

        return {'message': 'Data saved successfully'}, 201

    def get(self):
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT person_num, congestion_level FROM congestion ORDER BY timestamp DESC LIMIT 1")
        result = cursor.fetchone()

        if result:
            person_num, congestion_status = result
            person_num = int(person_num)  # 정수로 변환
        else:
            person_num, congestion_status = 0, '데이터 없음'

        cursor.close()
        conn.close()

        return {
            'person_count': person_num,
            'congestion_status': congestion_status
        }
# Resource 등록
api.add_resource(Congestion, '/congestion')