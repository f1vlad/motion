import cv2
from ultralytics import YOLO

# Load YOLOv8 model pretrained on COCO (supports "person" class)
model = YOLO('yolov8n.pt')  # Use yolov8s.pt or yolov8m.pt for better accuracy

# Path to your video file
video_path = "2025-07-24 08-32-32.mov"
cap = cv2.VideoCapture(video_path)

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    # Run inference
    results = model(frame)

    # Loop over detections
    for r in results:
        for box in r.boxes:
            cls = int(box.cls[0])
            conf = box.conf[0]

            # Class 0 is "person" in COCO dataset
            if cls == 0 and conf > 0.5:
                x1, y1, x2, y2 = map(int, box.xyxy[0])
                cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                cv2.putText(frame, f'Person {conf:.2f}', (x1, y1 - 10),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)

    # Show result
    cv2.imshow('People Detection', frame)
    if cv2.waitKey(1) == 27:  # ESC to quit
        break

cap.release()
cv2.destroyAllWindows()
