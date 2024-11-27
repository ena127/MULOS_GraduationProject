from flask import Flask
from flask_cors import CORS
from config import Config
from flask_restful import Api
from resources.users import users_bp
from resources.devices import devices_bp
from resources.returns import returns_bp
from resources.rentals import rentals_bp
from utils.upload_image import upload_bp
from auth.auth_routes import auth_bp
from resources.congestion import congestion_bp
from resources.professors import professors_bp
from utils.qrcode import qrcode_bp

import logging

logging.basicConfig(level=logging.DEBUG) # 요청이 제대로 전달되고 있는지 확인


app = Flask(__name__)
CORS(app)
api = Api(app)

# config.py 파일에서 설정 로드
app.config.from_object(Config)


# Blueprint 등록
app.register_blueprint(users_bp, url_prefix='/users')
app.register_blueprint(devices_bp, url_prefix='/devices')
app.register_blueprint(returns_bp, url_prefix='/returns')
app.register_blueprint(rentals_bp, url_prefix='/rentals')
app.register_blueprint(auth_bp, url_prefix='/auth')
app.register_blueprint(congestion_bp)
app.register_blueprint(upload_bp, url_prefix='/upload')
app.register_blueprint(professors_bp, url_prefix='/professors')
app.register_blueprint(qrcode_bp, url_prefix='/qrcode')  # utils.qrcode의 Blueprint


# Flask 서버 실행
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)