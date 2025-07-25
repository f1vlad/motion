#!/usr/bin/env python3
"""
Detects people, vehicles, and animals in a video file, logging each detection
and saving an annotated video with bounding boxes.
Displays a rich progress UI in the terminal.

Usage:
    python motion_detect_people.py <path_to_video_file>
"""

import sys
import os
import cv2
import logging
import datetime
from ultralytics import YOLO
from ultralytics.utils import LOGGER

from rich.live import Live
from rich.panel import Panel
from rich.progress import Progress, BarColumn, TextColumn, TimeRemainingColumn
from rich.text import Text
from rich.console import Group

def process_video(video_path):
    """
    Processes a video, logging detections to a file and showing progress in the terminal.
    """
    # --- File Validation & Setup ---
    if not os.path.isfile(video_path):
        print(f"[ERROR] File not found: {video_path}")
        sys.exit(1)

    log_filename = f"{os.path.splitext(video_path)[0]}_detections.log"
    logging.basicConfig(
        level=logging.INFO,
        format='%(message)s',
        filename=log_filename,
        filemode='w'
    )
    print(f"[INFO] Detections will be saved to: {log_filename}")

    LOGGER.setLevel("ERROR")
    model = YOLO('yolov8n.pt')
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"[ERROR] Failed to open video: {video_path}")
        sys.exit(1)

    # --- Video Writer Setup ---
    output_video_path = f"{os.path.splitext(video_path)[0]}_annotated.mp4"
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out_fps = cap.get(cv2.CAP_PROP_FPS)
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    out = cv2.VideoWriter(output_video_path, fourcc, out_fps, (width, height))
    print(f"[INFO] Annotated video will be saved to: {output_video_path}")
    # --- End Video Writer Setup ---

    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    fps = cap.get(cv2.CAP_PROP_FPS)

    # NEW: Initialize counters for all three categories
    total_persons_found = 0
    total_vehicles_found = 0
    total_animals_found = 0

    # Define class IDs for each category
    vehicle_ids = [1, 2, 3, 5, 7] # bicycle, car, motorcycle, bus, truck
    animal_ids = [14, 15, 16, 17, 18, 19, 20, 21, 22, 23] # All 10 animal classes

    # --- Rich UI Setup ---
    progress = Progress(
        TextColumn(" "),
        BarColumn(bar_width=30, style="cyan", complete_style="magenta"),
        TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
        TimeRemainingColumn(),
    )

    detection_task = progress.add_task("Processing...", total=total_frames)

    def generate_layout() -> Panel:
        # NEW: Create text displays for all three counters
        persons_text = Text(f"✓ Persons: {total_persons_found}", style="cyan")
        vehicles_text = Text(f"✓ Vehicles: {total_vehicles_found}", style="cyan")
        animals_text = Text(f"✓ Animals: {total_animals_found}", style="cyan")

        # Group all UI elements together
        ui_group = Group(persons_text, vehicles_text, animals_text, progress)
        return Panel(ui_group, title="[bold]Detection Status[/bold]", border_style="dim")

    # --- Main Processing Loop ---
    with Live(generate_layout(), refresh_per_second=10, screen=False) as live:
        while not progress.finished:
            ret, frame = cap.read()
            if not ret:
                break

            results = model(frame)

            # Draw bounding boxes on the frame
            annotated_frame = results[0].plot()

            # Write the annotated frame to the output video
            out.write(annotated_frame)

            for r in results:
                for box in r.boxes:
                    cls_id = int(box.cls[0])
                    confidence = float(box.conf[0])

                    if confidence > 0.5:
                        current_seconds = progress.tasks[detection_task].completed / fps
                        video_timestamp = str(datetime.timedelta(seconds=int(current_seconds)))
                        class_name = model.names.get(cls_id, "Unknown")
                        log_message = f"[{video_timestamp}] Detected '{class_name}' (Confidence: {confidence:.2f})"
                        logging.info(log_message)

                        # NEW: Check for person, vehicle, or animal and increment correct counter
                        if cls_id == 0:
                            total_persons_found += 1
                        elif cls_id in vehicle_ids:
                            total_vehicles_found += 1
                        elif cls_id in animal_ids:
                            total_animals_found += 1

            progress.update(detection_task, advance=1)
            live.update(generate_layout())

    # --- Cleanup ---
    cap.release()
    out.release() # Release the video writer
    cv2.destroyAllWindows()

    # NEW: Update the final summary to include all three counts
    print(f"\n[SUMMARY] Found a total of {total_persons_found} persons, {total_vehicles_found} vehicles, and {total_animals_found} animals.")
    print("[INFO] Processing complete.")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: python {os.path.basename(__file__)} <video_file>")
        sys.exit(1)

    input_video_path = sys.argv[1]
    process_video(input_video_path)
