import cv2
import sys

video_path = sys.argv[1] if len(sys.argv) > 1 else "input.mov"

cap = cv2.VideoCapture(video_path)
ret, frame1 = cap.read()
ret, frame2 = cap.read()

frame_count = 0

while cap.isOpened() and ret:
    diff = cv2.absdiff(frame1, frame2)
    gray = cv2.cvtColor(diff, cv2.COLOR_BGR2GRAY)
    blur = cv2.GaussianBlur(gray, (5, 5), 0)
    _, thresh = cv2.threshold(blur, 25, 255, cv2.THRESH_BINARY)
    contours, _ = cv2.findContours(thresh, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

    motion_detected = any(cv2.contourArea(c) > 1000 for c in contours)

    if motion_detected:
        print(f"Motion detected at frame {frame_count}")

    frame1 = frame2
    ret, frame2 = cap.read()
    frame_count += 1

cap.release()
