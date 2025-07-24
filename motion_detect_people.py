import sys
import os
import cv2
from ultralytics import YOLO

# --- Command-line argument parsing ---
if len(sys.argv) != 2:
    print(f"Usage: python {os.path.basename(__file__)} <video_file>")
    sys.exit(1)

video_path = sys.argv[1]

if not os.path.isfile(video_path):
    print(f"[ERROR] File not found: {video_path}")
    sys.exit(1)

# --- Load model ---
model = YOLO('yolov8n.pt')  # Use 'yolov8s.pt' or 'yolov8m.pt' for better accuracy

# --- Open video ---
cap = cv2.VideoCapture(video_path)
if not cap.isOpened():
    print(f"[ERROR] Failed to open video: {video_path}")
    sys.exit(1)

fps = cap.get(cv2.CAP_PROP_FPS)
total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
duration = total_frames / fps if fps else 0

print(f"[INFO] Video loaded: {video_path}")
print(f"[INFO] FPS: {fps:.1f}, Total Frames: {total_frames}, Duration: {duration:.2f} sec")

frame_idx = 0

# --- Process frames ---
while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    results = model(frame)

    for r in results:
        for box in r.boxes:
            cls = int(box.cls[0])
            conf = float(box.conf[0])
            label = model.model.names[cls]

            if cls == 0 and conf > 0.5:  # Person detected
                x1, y1, x2, y2 = map(int, box.xyxy[0])
                print(f"[DETECTED] Person @ frame {frame_idx}, confidence: {conf:.2f}")
                cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                cv2.putText(frame, f'Person {conf:.2f}', (x1, y1 - 10),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)

    cv2.imshow('People Detection', frame)
    if cv2.waitKey(1) == 27:  # ESC to quit
        break

    frame_idx += 1

cap.release()
cv2.destroyAllWindows()
