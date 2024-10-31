from flask import Flask, jsonify, request
from flask_restful import Resource, Api
from app import get_db_connection
from datetime import datetime

class Rentals(Resource):
# 대여 기록 추가 (POST /rentals)
#@app.route('/rentals', methods=['POST'])
    def post(self):
        data = request.json
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

        if not data or 'student_id' not in data:
            return jsonify({'error': 'Missing required fields'}), 400 

        return jsonify({'message': '대여 기록이 추가되었습니다!'}), 201