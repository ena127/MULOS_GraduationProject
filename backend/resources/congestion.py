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
        person_count = data.get('person_count', 0)  # 기본값을 0으로 설정
        congestion_ratio = data.get('congestion_ratio', None)

        # 혼잡도 상태를 결정
        if congestion_ratio is not None:
            if congestion_ratio <= 0.333:
                congestion_status = '쾌적'
            elif congestion_ratio > 0.666:
                congestion_status = '혼잡'
            else:
                congestion_status = '보통'
        else:
            congestion_status = None

        # 데이터베이스에 저장
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO congestion (person_num, congestion_ratio, congestion_level) VALUES (%s, %s, %s)",
            (person_count, congestion_ratio, congestion_status)
        )
        conn.commit()
        cursor.close()
        conn.close()

        return {'message': f'Saved person count {person_count}, congestion ratio {congestion_ratio}, and congestion status {congestion_status} to congestion table.'}, 201

    def get(self):
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT AVG(person_num) FROM congestion")
        average_person_count = cursor.fetchone()[0]  # 평균 혼잡도 계산

        if average_person_count is not None:
            # 혼잡도를 0과 1 사이로 정규화했다고 가정
            congestion_ratio = average_person_count

            # 혼잡도에 따른 상태
            if congestion_ratio <= 0.333:
                congestion_status = '쾌적'
            elif congestion_ratio > 0.666:
                congestion_status = '혼잡'
            else:
                congestion_status = '보통'
        else:
            congestion_status = '데이터 없음'

        cursor.close()
        conn.close()

        return {'congestion_status': congestion_status}

# Resource 등록
api.add_resource(Congestion, '/congestion')