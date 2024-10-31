from flask import Blueprint, jsonify, request
from flask_restful import Resource, Api
from database import get_db_connection

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
        student_id = data.get('student_id')
        role = data.get('role')
        email = data.get('email')
        name = data.get('name')
        photo_url = data.get('photo_url')
        professor = data.get('professor')

        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO user (student_id, role, email, name, photo_url, professor) VALUES (%s, %s, %s, %s, %s, %s)',
            (student_id, role, email, name, photo_url, professor)
        )
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({'message': '사용자가 추가되었습니다!'}), 201

# Users 클래스를 Blueprint에 등록
api.add_resource(Users, '', '/<int:user_id>')