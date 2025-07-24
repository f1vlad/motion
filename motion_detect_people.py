#!/usr/bin/env python3
"""
Detects people in a video file using the YOLOv8 model and displays a progress bar.

Usage:
    python motion_detect_people.py <path_to_video_file>
"""

import sys
import os
import cv2
from ultralytics import YOLO
from ultralytics.utils import LOGGER
from tqdm import tqdm

def process_video(video_path):
    """
    Processes a video to detect people, displaying the output with a progress bar.
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

    # Get video properties for the progress bar
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    print(f"[INFO] Video loaded: {os.path.basename(video_path)}")

    # --- Main Processing Loop with tqdm Progress Bar ---
    with tqdm(total=total_frames, unit="frame", desc="[INFO] Processing") as pbar:
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break  # End of video

            # Run YOLOv8 inference on the frame
            results = model(frame)

            # Process detection results
            for r in results:
                for box in r.boxes:
                    # Check if the detected object is a person (class ID 0)
                    if int(box.cls[0]) == 0:
                        confidence = float(box.conf[0])
                        # Set a confidence threshold
                        if confidence > 0.5:
                            # Use tqdm.write() to print messages without disturbing the bar
                            tqdm.write(f"[DETECTED] Person @ frame {int(pbar.n)}, confidence: {confidence:.2f}")

                            # Get bounding box coordinates and draw on the frame
                            x1, y1, x2, y2 = map(int, box.xyxy[0])
                            cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                            label = f'Person {confidence:.2f}'
                            # This is the corrected line
                            cv2.putText(frame, label, (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)

            # --- Show Detection Window ---
            cv2.imshow('People Detection', frame)
            # Allow exit with ESC key
            if cv2.waitKey(1) & 0xFF == 27:
                tqdm.write("\n[INFO] Exiting on user request.")
                break

            # Update the progress bar by one frame
            pbar.update(1)

    # --- Cleanup ---
    cap.release()
    cv2.destroyAllWindows()
    print("\n[INFO] Processing complete.")


# This block ensures the script runs when called from the command line
if __name__ == "__main__":
    # Check for the video file argument
    if len(sys.argv) != 2:
        print(f"Usage: python {os.path.basename(__file__)} <video_file>")
        sys.exit(1)

    # Get the video path and start processing
    input_video_path = sys.argv[1]
    process_video(input_video_path)
