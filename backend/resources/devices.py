from flask import Blueprint, jsonify, request
from flask_restful import Resource, Api
from .database import get_db_connection

# Blueprint 생성
devices_bp = Blueprint('devices', __name__)
api = Api(devices_bp)

# 기기 조회 (GET /devices)
class Devices(Resource):
    def get(self, device_id=None):
        conn = get_db_connection()
        cursor = conn.cursor()

        # 특정 기기 조회 또는 전체 기기 조회
        if device_id:
            cursor.execute('SELECT * FROM device WHERE device_id = %s', (device_id,))
            device = cursor.fetchone()
            if not device:
                return {'error': 'Device not found'}, 404

            device_data = {
                'device_id': device[0],
                'type': device[1],
                'model': device[2],
                'availability': device[3],
                'created_at': device[4],
                'device_name': device[5],
                'memo': device[6]
            }
            cursor.close()
            conn.close()
            return jsonify(device_data)
        else:
            cursor.execute('SELECT * FROM device')
            devices = cursor.fetchall()
            cursor.close()
            conn.close()

            devices_list = [
                {
                    'device_id': device[0],
                    'type': device[1],
                    'model': device[2],
                    'availability': device[3],
                    'created_at': device[4],
                    'device_name': device[5],
                    'memo': device[6]
                }
                for device in devices
            ]

            return jsonify(devices_list)

    # 기기 추가 (POST /devices)
    def post(self):
        data = request.json
        device_type = data.get('type')

        # ENUM 타입 유효성 검사
        valid_types = ['window', 'mac', 'galaxy tab', 'ipad', 'accessary']
        if device_type not in valid_types:
            return {'error': 'Invalid device type'}, 400

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

        return {'message': '기기가 추가되었습니다!'}, 201


# 기기 타입 목록 조회 (GET /devices/types)
class DeviceTypes(Resource):
    def get(self):
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT DISTINCT type FROM device")
        types = [row[0] for row in cursor.fetchall()]
        cursor.close()
        conn.close()
        return jsonify(types)


# 모델 목록 조회 (GET /devices/models)
class DeviceModels(Resource):
    def get(self):
        device_type = request.args.get('type')
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT DISTINCT model FROM device WHERE type = %s", (device_type,))
        models = [row[0] for row in cursor.fetchall()]
        cursor.close()
        conn.close()
        return jsonify(models)


# 사용 가능한 기기 조회 (GET /devices/available)
class AvailableDevices(Resource):
    def get(self):
        model = request.args.get('model')
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT device_name FROM device WHERE model = %s AND availability = 1", (model,))
        devices = [row[0] for row in cursor.fetchall()]
        cursor.close()
        conn.close()
        return jsonify(devices)


# 기기 대여 (POST /devices/rent)
class RentDevice(Resource):
    def post(self):
        data = request.json
        device_name = data.get('device_name')

        if not device_name:
            return {'error': 'Device name is required'}, 400

        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('UPDATE device SET availability = 0 WHERE device_name = %s AND availability = 1', (device_name,))
        if cursor.rowcount == 0:
            cursor.close()
            conn.close()
            return {'error': 'Device is not available'}, 404

        conn.commit()
        cursor.close()
        conn.close()

        return {'message': 'Device rented successfully'}, 200


# Blueprint에 Resource 추가
api.add_resource(Devices, '', '/<int:device_id>')
api.add_resource(DeviceTypes, '/types')
api.add_resource(DeviceModels, '/models')
api.add_resource(AvailableDevices, '/available')
api.add_resource(RentDevice, '/rent')