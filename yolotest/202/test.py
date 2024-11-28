from ultralytics import YOLO
import cv2

# Load the YOLOv8 model
model = YOLO('best_202.pt')

# Input and output video paths
input_video_path = 'C:/Users/jun08/Desktop/yolotest/202/test5.mp4'
output_video_path = 'test5_onlyperson_video_202.mp4'

# Open the input video
cap = cv2.VideoCapture(input_video_path)
frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
fps = int(cap.get(cv2.CAP_PROP_FPS))

# Set up the output video writer
out = cv2.VideoWriter(output_video_path, cv2.VideoWriter_fourcc(*'mp4v'), fps, (frame_width, frame_height))

frame_count = 0

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    # Perform object detection for every frame (detect only "person" class)
    results = model(frame)  # Perform detection

    # Filter only "person" class detections
    person_detections = results[0].boxes[results[0].boxes.cls == 0]  # `cls` contains the class indices
    
    # Annotate the frame with person detections
    for box in person_detections:
        x1, y1, x2, y2 = map(int, box.xyxy[0])  # Extract bounding box coordinates
        conf = float(box.conf[0])  # Extract confidence score
        label = f'Person {conf:.2f}'  # Format label with confidence
        
        cv2.rectangle(frame, (x1, y1), (x2, y2), (255, 0, 0), 2)  # Draw bounding box
        cv2.putText(frame, label, (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 0, 0), 2)  # Add label

    # Write the annotated frame to the output video
    out.write(frame)

    frame_count += 1

# Release resources
cap.release()
out.release()
