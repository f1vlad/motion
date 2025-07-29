#!/bin/bash

CAPTURE_DIR="capture"
PID_FILE="$CAPTURE_DIR/ffmpeg.pid"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE" | tr -d '\n')
    if [ -n "$PID" ]; then
        echo "Stopping video capture (PID: $PID)..."
        kill -9 $PID
        rm "$PID_FILE"
        echo "Capture stopped."
    else
        echo "Error: PID file exists but is empty. Removing stale PID file."
        rm "$PID_FILE"
    fi
else
    echo "Error: Capture is not running (PID file not found)."
fi
