from resources.database import get_db_connection
from utils.hashing import hash_password, verify_password
import jwt
from datetime import datetime, timedelta
from flask_cors import CORS
from flask import Flask


# Flask 앱 초기화 시 CORS 설정
app = Flask(__name__)
CORS(app)

SECRET_KEY = 'secretKey'

def register_user(user_data):
    print(f"[DEBUG] Received user data: {user_data}")

    student_id = user_data.get('student_id')
    password = hash_password(user_data.get('password'))
    role = user_data.get('role')
    email = user_data.get('email')
    name = user_data.get('name')
    photo_url = user_data.get('photo_url', None)
    professor = user_data.get('professor', None)

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            '''
            INSERT INTO user (student_id, role, email, name, password, photo_url, professor)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            ''',
            (student_id, role, email, name, password, photo_url, professor)
        )
        conn.commit()
        cursor.close()
        conn.close()

        print("[DEBUG] User registered successfully")
        return {"message": "User registered successfully"}, 200

    except Exception as e:
        print(f"[ERROR] Database insertion failed: {e}")
        return {"error": "Database error"}, 500


def login_user(user_data):
    """Logs in a user and returns user data with a JWT token if valid."""
    if 'student_id' not in user_data or 'password' not in user_data:
        return {"error": "Missing student_id or password"}, 400

    student_id = user_data['student_id']
    password = user_data['password']

    print(f"로그인 시도 - 학번: {student_id}")

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            'SELECT student_id, role, email, name, photo_url, professor, password FROM user WHERE student_id = %s',
            (student_id,)
        )
        user = cursor.fetchone()

        if not user:
            return {"error": "User not found"}, 404

        hashed_password = user[6]
        if not verify_password(password, hashed_password):
            return {"error": "Invalid credentials"}, 401

        # JWT 토큰 생성
        token = jwt.encode(
            {'student_id': student_id, 'exp': datetime.utcnow() + timedelta(hours=1)},
            SECRET_KEY, algorithm='HS256'
        )

        # 사용자 정보 포함 응답 생성
        response = {
            "token": token,
            "user": {
                "student_id": user[0],
                "role": user[1],
                "email": user[2],
                "name": user[3],
                "photo_url": user[4],
                "professor": user[5]
            }
        }
        print(f"[DEBUG] Response data: {response}")
        return response, 200

    except Exception as e:
        print(f"[ERROR] Database query failed: {e}")
        return {"error": "Database error"}, 500
    finally:
        cursor.close()
        conn.close()