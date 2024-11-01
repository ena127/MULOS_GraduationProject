from flask import Flask
from flask_cors import CORS
from config import Config
from flask_restful import Api
from resources.users import users_bp
from resources.devices import devices_bp
from resources.returns import returns_bp
from resources.rentals import rentals_bp
import logging
logging.basicConfig(level=logging.DEBUG) # 요청이 제대로 전달되고 있는지 확인


import os
print(os.getcwd())


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


# Flask 서버 실행
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)