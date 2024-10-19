from flask import Flask, jsonify, request
from flask_cors import CORS
from datetime import datetime
from backend.config import Config
import pymysql

app = Flask(__name__)
CORS(app)

# config.py 파일에서 설정 로드
app.config.from_object(Config)


# MySQL 연결
def get_db_connection():
    try:
        conn = pymysql.connect(
            host=app.config['MYSQL_HOST'],
            user=app.config['MYSQL_USER'],
            password=app.config['MYSQL_PASSWORD'],
            db=app.config['MYSQL_DB'],
            port=3306,
            charset='utf8'
        )
        return conn
    except pymysql.MySQLError as e:
        print(f"Error connecting to database: {e}")
        return None

# 사용자 조회 (GET /users)
@app.route('/users', methods=['GET'])
def get_users():
    conn = get_db_connection()
    if conn is None:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = conn.cursor()
    try:
        cursor.execute('SELECT * FROM user')
        users = cursor.fetchall()
    finally:
        cursor.close()
        conn.close()

    users_list = []
    for user in users:
        users_list.append({
            'user_id': user[0],
            'student_id': user[1],
            'role': user[2],
            'email': user[3],
            'name': user[4],
            'photo_url': user[5],
            'professor': user[6]
        })

    return jsonify(users_list)

# 사용자 추가 (POST /users)
@app.route('/users', methods=['POST'])
def create_user():
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

# 기기 조회 (GET /devices)
@app.route('/devices', methods=['GET'])
def get_devices():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM device')
    devices = cursor.fetchall()
    cursor.close()
    conn.close()

    devices_list = []
    for device in devices:
        devices_list.append({
            'device_id': device[0],
            'type': device[1],
            'model': device[2],
            'availability': device[3],
            'created_at': device[4],
            'device_name': device[5],
            'memo': device[6]
        })

    return jsonify(devices_list)

# 기기 추가 (POST /devices)
@app.route('/devices', methods=['POST'])
def create_device():
    data = request.json
    device_type = data.get('type')

    # ENUM 타입 유효성 검사
    valid_types = ['window', 'mac', 'galaxy tab', 'ipad', 'accessary']
    if device_type not in valid_types:
        return jsonify({'error': 'Invalid device type'}), 400
    
    model = data.get('model')
    availability = data.get('availability')
    device_name = data.get('device_name')
    memo = data.get('memo')

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        'INSERT INTO device (type, model, availability, device_name, memo) VALUES (%s, %s, %s, %s, %s)',
        (device_type, model, availability, device_name, memo)
    )
    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({'message': '기기가 추가되었습니다!'}), 201

# 대여 기록 추가 (POST /rentals)
@app.route('/rentals', methods=['POST'])
def create_rental():
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



# 반납 기록 추가 (POST /returns)
@app.route('/returns', methods=['POST'])
def create_return():
    data = request.json
    rental_id = data.get('rental_id')
    return_date = datetime.strptime(data.get('return_date'), '%Y-%m-%dT%H:%M:%S')
    photo_url = data.get('photo_url')
    status = data.get('status')
    condition = data.get('condition')

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        'INSERT INTO return (rental_id, return_date, photo_url, status, condition) VALUES (%s, %s, %s, %s, %s)',
        (rental_id, return_date, photo_url, status, condition)
    )
    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({'message': '반납 기록이 추가되었습니다!'}), 201

# Flask 서버 실행
if __name__ == '__main__':
    app.run(debug=True)