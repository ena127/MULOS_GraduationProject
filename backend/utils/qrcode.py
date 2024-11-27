from flask import Flask, jsonify, request, send_file, make_response
import pymysql
import qrcode
from PIL import Image
from io import BytesIO
from datetime import datetime
from flask import Blueprint
from flask_restful import Resource, Api
from .database import get_db_connection

# Blueprint 생성
qrcode_bp = Blueprint('qrcode', __name__)
api = Api(qrcode_bp)  # Blueprint에 Api 객체 연결

class GenerateCode(Resource):
    def post(self):
        try:
            data = request.json
            if not data:
                return {'error': 'Invalid JSON data'}, 400

            student_id = data.get('student_id')

            # student_id 유효성 검사
            if not student_id:
                return {'error': 'student_id is required'}, 400

            conn = get_db_connection()
            cursor = conn.cursor()
            cursor.execute('SELECT student_id FROM user WHERE student_id = %s', (student_id,))
            result = cursor.fetchone()
            cursor.close()
            conn.close()

            if not result:
                return {'error': 'User not found'}, 404

            # QR 코드 생성
            qr = qrcode.make(student_id)
            buffer = BytesIO()
            qr.save(buffer, format="PNG")
            buffer.seek(0)

            # QR 코드 이미지 반환
            response = make_response(buffer.getvalue())
            response.headers.set('Content-Type', 'image/png')
            response.headers.set('Content-Disposition', 'inline; filename=qr_code.png')

            return response

        except Exception as e:
            return {'error': str(e)}, 500

class CheckID(Resource):
    def post(self):
        try:
            data = request.json
            if not data:
                return {'error': 'Invalid JSON data'}, 400

            student_id = data.get('student_id')

            # student_id 유효성 검사
            if not student_id:
                return {'error': 'student_id is required'}, 400

            conn = get_db_connection()
            cursor = conn.cursor()
            cursor.execute('SELECT student_id FROM user WHERE student_id = %s', (student_id,))
            result = cursor.fetchone()
            cursor.close()
            conn.close()

            if result:
                return {'status': 1}  # student_id가 데이터베이스에 존재함
            else:
                return {'status': 0} # student_id가 데이터베이스에 존재하지 않음

        except Exception as e:
            return {'error': str(e)}, 500

# API 경로에 Resource 추가
api.add_resource(GenerateCode, '/generate_qr')
api.add_resource(CheckID, '/scan_qr')