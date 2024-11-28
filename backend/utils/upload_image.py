from flask import Blueprint, request, jsonify
import os
from flask_restful import Resource, Api

upload_bp = Blueprint('upload', __name__)
api = Api(upload_bp)
UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

class Upload(Resource):
    def post(self):
        if 'image' not in request.files:
            return {"error": "No image file provided"}, 400

        image = request.files['image']
        image_path = os.path.join(UPLOAD_FOLDER, image.filename)
        image.save(image_path)

        # URL 반환
        photo_url = f'http://3.39.184.195:5000/{UPLOAD_FOLDER}/{image.filename}'

        return {"photo_url": photo_url}, 200
api.add_resource(Upload, '/upload')
# 정적 파일 경로 등록
@upload_bp.route('/uploads/<filename>', methods=['GET'])
def uploaded_file(filename):
    return send_from_directory(UPLOAD_FOLDER, filename)
