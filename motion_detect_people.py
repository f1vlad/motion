#!/usr/bin/env python3
"""
Detects people and vehicles in a video file using the YOLOv8 model and displays a rich progress UI.

Usage:
    python motion_detect_people.py <path_to_video_file>
"""

import sys
import os
import cv2
from ultralytics import YOLO
from ultralytics.utils import LOGGER

# Import necessary components from the 'rich' library
from rich.live import Live
from rich.panel import Panel
from rich.progress import Progress, BarColumn, TextColumn, TimeRemainingColumn
from rich.text import Text
from rich.console import Group

def process_video(video_path):
    """
    Processes a video using a rich, compact terminal UI for progress.
    """
    # --- File Validation & Setup ---
    if not os.path.isfile(video_path):
        print(f"[ERROR] File not found: {video_path}")
        sys.exit(1)

    LOGGER.setLevel("ERROR") # Set logger to ERROR to keep output clean
    model = YOLO('yolov8n.pt')
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"[ERROR] Failed to open video: {video_path}")
        sys.exit(1)

    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

    # NEW: Initialize counters for both persons and vehicles
    total_persons_found = 0
    total_vehicles_found = 0

    # NEW: Define the class IDs for vehicles from the COCO dataset
    # car: 2, motorcycle: 3, bus: 5, truck: 7
    vehicle_ids = [2, 3, 5, 7]

    # --- Rich UI Setup ---
    progress = Progress(
        TextColumn(" "),
        BarColumn(bar_width=30, style="blue", complete_style="magenta"),
        TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
        TimeRemainingColumn(),
    )

    detection_task = progress.add_task("Processing...", total=total_frames)

    def generate_layout() -> Panel:
        """Creates the panel layout for the live display."""
        # UPDATED: Create text displays for both counters
        persons_text = Text(f"✓ Persons: {total_persons_found}", style="green")
        vehicles_text = Text(f"✓ Vehicles: {total_vehicles_found}", style="cyan")

        # UPDATED: Group all UI elements together
        ui_group = Group(persons_text, vehicles_text, progress)

        return Panel(ui_group, title="[bold]Detection Status[/bold]", border_style="dim")

    # --- Main Processing Loop with Rich Live Display ---
    with Live(generate_layout(), refresh_per_second=10, screen=False) as live:
        while not progress.finished:
            ret, frame = cap.read()
            if not ret:
                break

            results = model(frame)

            for r in results:
                for box in r.boxes:
                    cls_id = int(box.cls[0])
                    confidence = float(box.conf[0])

                    if confidence > 0.5:
                        # UPDATED: Check for person OR vehicle and increment the correct counter
                        if cls_id == 0: # Person
                            total_persons_found += 1
                        elif cls_id in vehicle_ids: # Vehicle
                            total_vehicles_found += 1

            progress.update(detection_task, advance=1)
            live.update(generate_layout())

    # --- Cleanup ---
    cap.release()
    cv2.destroyAllWindows()

    # UPDATED: Print a final summary including both counts
    print(f"\n[SUMMARY] Found a total of {total_persons_found} persons and {total_vehicles_found} vehicles.")
    print("[INFO] Processing complete.")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: python {os.path.basename(__file__)} <video_file>")
        sys.exit(1)

    input_video_path = sys.argv[1]
    process_video(input_video_path)
