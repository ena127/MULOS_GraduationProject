from flask import Blueprint, jsonify, request
from flask_restful import Resource, Api
from database import get_db_connection
import pymysql

# 10.31 Flask-RESTful은 dict를 반환하면 자동으로 JSON으로 직렬화 함으로, 에러 메시지를 딕셔너리 형태로 반환 (jsonify로 반환하던것 수정)

# Blueprint 생성
users_bp = Blueprint('users', __name__)
api = Api(users_bp)  # Blueprint에 Api 객체 연결

class Users(Resource):
    # 사용자 조회 (GET /users)
    # @app.route('/users', methods=['GET'])
    def get(self, user_id = None):
        conn = get_db_connection()
        if conn is None:
            return jsonify({'error': 'Database connection failed'}), 500

        cursor = conn.cursor()
        try:
            if user_id:
                cursor.execute('SELECT * FROM user WHERE user_id = %s', (user_id,))
                user = cursor.fetchone()
                if user:
                    user_data = {
                        'user_id': user[0],
                        'student_id': user[1],
                        'role': user[2],
                        'email': user[3],
                        'name': user[4],
                        'photo_url': user[5],
                        'professor': user[6]
                    }
                    return jsonify(user_data)
                else:
                    return jsonify({'error': 'User not found'}), 404
            else:
                cursor.execute('SELECT * FROM user')
                users = cursor.fetchall()
                users_list = [{'user_id': user[0], 'student_id': user[1], 'role': user[2], 'email': user[3], 'name': user[4], 'photo_url': user[5], 'professor': user[6]} for user in users]
                return jsonify(users_list)
        finally:
            cursor.close()
            conn.close()




    # 사용자 추가 (POST /users)
    #@app.route('/users', methods=['POST'])
    def post(self):
 
        data = request.json
        print("Received data:", data)  # 디버깅: 수신된 데이터 출력 

        student_id = data.get('student_id')
        role = data.get('role')
        email = data.get('email')
        name = data.get('name')
        photo_url = data.get('photo_url')
        professor = data.get('professor')
    
        print("Student ID:", student_id)  # 디버깅: 필드 값 확인
        if not all([student_id, role, email, name]): # 네 개 다 값 존재하면 True, 하나라도 없으면 False
            return {"error": "Missing required fields"}, 400  # dict로 반환

        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            cursor.execute(
                'INSERT INTO user (student_id, role, email, name, photo_url, professor) VALUES (%s, %s, %s, %s, %s, %s)',
                (student_id, role, email, name, photo_url, professor)
            )
            conn.commit()
            return {"message": "User added successfully"}, 201  # dict로 반환

        except pymysql.MySQLError as e:
            print(f"Database error: {e}")
            conn.rollback()
            return {"error": "Failed to insert data"}, 500  # dict로 반환

        finally:
            cursor.close()
            conn.close()


# Users 클래스를 Blueprint에 등록
api.add_resource(Users, '', '/<int:user_id>')