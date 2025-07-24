import cv2
import time
from ultralytics import YOLO

# Load YOLOv8 model
model = YOLO('yolov8n.pt')  # Or yolov8s.pt / yolov8m.pt for more accuracy

# Input and output video
video_path = "2025-07-24 08-32-32.mov"
output_path = "output_people_detected.mp4"
cap = cv2.VideoCapture(video_path)

# Get video properties
fps = cap.get(cv2.CAP_PROP_FPS)
frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
duration = frame_count / fps

print(f"[INFO] Video loaded: {video_path}")
print(f"[INFO] FPS: {fps}, Total Frames: {frame_count}, Duration: {duration:.2f} sec")

# Define video writer
fourcc = cv2.VideoWriter_fourcc(*'mp4v')  # Use 'avc1' or 'H264' if 'mp4v' doesn't work
out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))

start_time = time.time()

frame_idx = 0
while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    results = model(frame)

    # Draw people detections
    for r in results:
        for box in r.boxes:
            cls = int(box.cls[0])
            conf = box.conf[0]
            if cls == 0 and conf > 0.5:
                x1, y1, x2, y2 = map(int, box.xyxy[0])
                cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                cv2.putText(frame, f'Person {conf:.2f}', (x1, y1 - 10),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)

    out.write(frame)  # Save frame
