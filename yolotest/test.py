import os
import cv2
import requests
from ultralytics import YOLO

# 현재 파일의 디렉토리를 기준으로 절대 경로 생성
current_dir = os.path.dirname(os.path.abspath(__file__))
weights_path = os.path.join(current_dir, 'yolov8n_202.pt')

# YOLO 모델 로드
print(f"Loading YOLO weights from {weights_path}")
model = YOLO(weights_path)

# 입력 및 출력 비디오 경로 설정
input_video_path = '/Users/inayeong/MULOS_GraduationProject/yolotest/final2.mp4'
output_video_path = 'output2_onlyperson_video2.mp4'

# Flask API URL 설정
flask_api_url = 'http://3.39.184.195:5000/congestion'  # Flask 서버에 보낼 새로운 엔드포인트 URL

# 비디오 파일 확인
if not os.path.exists(input_video_path):
    print(f"Error: File not found at {input_video_path}")
    exit()

# 비디오 파일 열기
cap = cv2.VideoCapture(input_video_path)
if not cap.isOpened():
    print(f"Error: Could not open video file at {input_video_path}")
    exit()

print("Video opened successfully.")

# 비디오 속성 가져오기
frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
fps = int(cap.get(cv2.CAP_PROP_FPS))
print(f"Video FPS: {fps}, Resolution: {frame_width}x{frame_height}")

# 출력 비디오 작성기 설정
out = cv2.VideoWriter(output_video_path, cv2.VideoWriter_fourcc(*'mp4v'), fps, (frame_width, frame_height))

# 설정
frame_count = 0
update_interval = 50  # 매 50 프레임마다 전송
max_capacity = 60  # 최대 수용 인원 (60명)

# 프레임 처리
while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        print("End of video or error reading frame.")
        break

    # 프레임 번호 증가
    frame_count += 1
    print(f"Processing frame {frame_count}...")

    # YOLO 감지 (사람만 감지)
    results = model(frame, classes=[0])
    person_count = len(results[0].boxes)  # 감지된 사람 수
    congestion_ratio = person_count / max_capacity
    print(f"Frame {frame_count}: Detected {person_count} people, Congestion ratio: {congestion_ratio:.2f}")

    # POST 요청 보내기 (50 프레임마다)
    if frame_count % update_interval == 0:
        try:
            payload = {
                'person_count': person_count,
                'congestion_ratio': congestion_ratio
            }
            print(f"Frame {frame_count}: Sending payload: {payload}")
            response = requests.post(flask_api_url, json=payload)

            if response.status_code == 201:
                print(f"Frame {frame_count}: Data saved successfully.")
            else:
                print(f"Frame {frame_count}: Failed to save data - {response.status_code}, {response.text}")
        except Exception as e:
            print(f"Error sending data to Flask API at frame {frame_count}: {e}")

    # 탐지 결과를 프레임에 주석 추가
    annotated_frame = results[0].plot()

    # 주석이 추가된 프레임을 출력 비디오에 작성
    out.write(annotated_frame)
    print(f"Frame {frame_count} processed and written to output.")

# 자원 해제
cap.release()
out.release()
print("Video processing completed and resources released.")