import os
import cv2
import requests
from ultralytics import YOLO

# YOLOv8 모델 로드
model = YOLO('yolov8n.pt')

# 입력 및 출력 비디오 경로 설정
input_video_path = '/Users/inayeong/MULOS_GraduationProject/yolotest/final2.mp4'
output_video_path = 'output2_onlyperson_video2.mp4'

# Flask API URL 설정
flask_api_url = 'http://3.39.184.195:5000/congestion'  # Flask 서버에 보낼 새로운 엔드포인트 URL

# 1. 파일 경로와 존재 여부 확인
if not os.path.exists(input_video_path):
    print(f"Error: File not found at {input_video_path}")
else:
    print("File exists. Proceeding with video processing.")

    # 2. 비디오 파일 열기
    cap = cv2.VideoCapture(input_video_path)

    # 비디오 파일이 열리는지 확인
    if not cap.isOpened():
        print(f"Error: Could not open video file at {input_video_path}")
    else:
        print("Video opened successfully.")

        # 비디오 속성 가져오기
        frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fps = int(cap.get(cv2.CAP_PROP_FPS))

        # 출력 비디오 작성기 설정
        out = cv2.VideoWriter(output_video_path, cv2.VideoWriter_fourcc(*'mp4v'), fps, (frame_width, frame_height))

        # 프레임 처리
        frame_count = 0
        update_interval = 50  # 예를 들어, 매 10 프레임마다 전송


        # Define maximum capacity for congestion ratio calculation
        max_capacity = 60  # 최대 수용 인원 (예시로 60명을 설정)

        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break

            # Perform object detection for every frame (detect only "person" class)
            results = model(frame, classes=[0])
            person_count = len(results[0].boxes)  # 감지된 사람 수

            # Calculate congestion ratio based on person count
            congestion_ratio = person_count / max_capacity
            if frame_count % update_interval == 0:

                # Send the person count and congestion ratio to the Flask API
                try:
                    response = requests.post(flask_api_url, json={'person_count': person_count, 'congestion_ratio': congestion_ratio})
                    if response.status_code == 201:
                        print(f"Frame {frame_count}: Saved person count {person_count} and congestion ratio {congestion_ratio:.2f} to congestion table.")
                    else:
                        print(f"Failed to save person count for frame {frame_count}: {response.text}")
                except requests.exceptions.RequestException as e:
                    print(f"Failed to connect to API for frame {frame_count}: {e}")

            # 탐지 결과를 프레임에 주석 추가
            annotated_frame = results[0].plot()

            # 주석이 추가된 프레임을 출력 비디오에 작성
            out.write(annotated_frame)
            frame_count += 1

            print(f"Processed {frame_count} frames.")

        # 자원 해제 (루프가 끝난 후에 호출)
        cap.release()
        out.release()
        print("Video processing completed and resources released.")