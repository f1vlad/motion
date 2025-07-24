#!/usr/bin/env python3
"""
Detects people in a video file using the YOLOv8 model.

Usage:
    python motion_detect_people.py <path_to_video_file>
"""

import sys
import os
import cv2
from ultralytics import YOLO
from ultralytics.utils import LOGGER

def process_video(video_path):
    """
    Processes a video to detect people, displaying the output and printing detections.
    """
    # --- File Validation ---
    if not os.path.isfile(video_path):
        print(f"[ERROR] File not found: {video_path}")
        sys.exit(1)

    # --- Setup ---
    # Set the logging level to WARNING to hide unnecessary informational messages
    LOGGER.setLevel("WARNING")

    # Load the YOLOv8 model ('yolov8n.pt' is small and fast)
    print("[INFO] Loading YOLOv8 model...")
    model = YOLO('yolov8n.pt')
    print("[INFO] Model loaded successfully.")

    # Open the video file
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"[ERROR] Failed to open video: {video_path}")
        sys.exit(1)

    # Get video properties
    fps = cap.get(cv2.CAP_PROP_FPS)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    duration = total_frames / fps if fps > 0 else 0

    print(f"[INFO] Video loaded: {os.path.basename(video_path)}")
    print(f"[INFO] FPS: {fps:.1f}, Total Frames: {total_frames}, Duration: {duration:.2f} sec")

    frame_idx = 0

    # --- Main Processing Loop ---
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break # End of video

        # Run YOLOv8 inference on the frame
        results = model(frame)
        person_detected_in_frame = False
        highest_confidence = 0.0

        # Process results
        for r in results:
            for box in r.boxes:
                # Check if the detected object is a person (class ID 0)
                if int(box.cls[0]) == 0:
                    confidence = float(box.conf[0])
                    # Set a confidence threshold
                    if confidence > 0.5:
                        person_detected_in_frame = True
                        if confidence > highest_confidence:
                            highest_confidence = confidence

                        # Get bounding box coordinates and draw on the frame
                        x1, y1, x2, y2 = map(int, box.xyxy[0])
                        cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                        label = f'Person {confidence:.2f}'
                        cv2.putText(frame, label, (x1, y1 - 10),
                                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
                        print(f"\n[DETECTED] Person @ frame {frame_idx}, confidence: {confidence:.2f}")

        # --- Live Terminal Status (single line) ---
        progress_percent = (frame_idx / total_frames) * 100 if total_frames > 0 else 0
        status_text = (
            f"\r[PROCESSING] Frame {frame_idx}/{total_frames} ({progress_percent:.1f}%) | "
            f"Person Detected: {person_detected_in_frame} | "
            f"Confidence: {highest_confidence:.2f}   "
        )
        print(status_text, end="", flush=True)

        # --- Show Detection Window ---
        cv2.imshow('People Detection', frame)
        # Allow exit with ESC key
        if cv2.waitKey(1) & 0xFF == 27:
            print("\n[INFO] Exiting on user request.")
            break

        frame_idx += 1

    # --- Cleanup ---
    cap.release()
    cv2.destroyAllWindows()
    print("\n[INFO] Processing complete.")


if __name__ == "__main__":
    # --- Command-line argument parsing ---
    if len(sys.argv) != 2:
        print(f"Usage: python {os.path.basename(__file__)} <video_file>")
        sys.exit(1)

    input_video_path = sys.argv[1]
    process_video(input_video_path)
