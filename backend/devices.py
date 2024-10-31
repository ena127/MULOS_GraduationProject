from flask import Blueprint, jsonify, request
from flask_restful import Resource, Api
from database import get_db_connection


# Blueprint 생성
devices_bp = Blueprint('devices', __name__)
api = Api(devices_bp)  # Blueprint에 Api 객체 연결

# 기기 조회 (GET /devices)
# @app.route('/devices', methods=['GET'])

class Devices(Resource):
    def get(self, device_id=None):
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
    # @app.route('/devices', methods=['POST'])
    def post(self):
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

# Devices 클래스를 Blueprint에 등록
api.add_resource(Devices, '', '/<int:device_id>')