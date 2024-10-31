from flask import Flask, jsonify, request
from flask_cors import CORS
from config import Config
import pymysql
from flask_restful import Resource, Api
from datetime import datetime
from users import Users
from devices import Devices
from returns import Returns
from rentals import Rentals



import os
print(os.getcwd())


app = Flask(__name__)
CORS(app)
api = Api(app)

# config.py 파일에서 설정 로드
app.config.from_object(Config)

# 엔드포인트 정의
api.add_resource(Users, '/users', '/users/<int:user_id>')  # 사용자 조회 및 추가
api.add_resource(Devices, '/devices', '/devices/<int:device_id>')  # 기기 조회 및 추가
api.add_resource(Rentals, '/rentals', '/rentals/<int:rental_id>')  # 대여 기록 추가
api.add_resource(Returns, '/returns', '/returns/<int:return_id>')  # 반납 기록 추가

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
    

# Flask 서버 실행
if __name__ == '__main__':
    app.run(debug=True)