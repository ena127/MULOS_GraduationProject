from flask import Flask, jsonify, request, send_file, make_response
import pymysql
import qrcode
from PIL import Image
from io import BytesIO
from datetime import datetime
from flask import Blueprint
from flask_restful import Resource, Api
from .database import get_db_connection
from flask import send_file
from gtts import gTTS
import os

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

            # 인증 URL 생성
            auth_url = f"http://3.39.184.195:5000/qrcode/verify/{student_id}"
            print(f"Generated Auth URL: {auth_url}")  # 디버깅 로그 추가


            # QR 코드 생성 (인증 URL 포함)
            qr = qrcode.make(auth_url)
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

class VerifyStudent(Resource):
    def get(self, student_id):
        try:
            # student_id 유효성 검사
            if not student_id:
                return {'error': 'student_id is required'}, 400

            conn = get_db_connection()
            cursor = conn.cursor()
            cursor.execute('SELECT student_id FROM user WHERE student_id = %s', (student_id,))
            result = cursor.fetchone()
            cursor.close()
            conn.close()

            # 명시적으로 프로젝트 루트 디렉토리 설정
            project_root = "/home/ec2-user/MULOS_GraduationProject"  # 프로젝트 루트 디렉토리
            success_path = os.path.join(project_root, 'success.mp3')
            fail_path = os.path.join(project_root, 'fail.mp3')

            if result:
                # 인증 성공 시 파일 반환
                return send_file(success_path, mimetype="audio/mpeg")
            else:
                # 인증 실패 시 파일 반환
                return send_file(fail_path, mimetype="audio/mpeg")

        except Exception as e:
            return {'error': str(e)}, 500


# API 경로에 Resource 추가
api.add_resource(GenerateCode, '/generate')
api.add_resource(CheckID, '/scan')
api.add_resource(VerifyStudent, '/verify/<string:student_id>')