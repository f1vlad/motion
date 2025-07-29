#!/bin/bash

CAPTURE_DIR="capture"
PID_FILE="$CAPTURE_DIR/ffmpeg.pid"

if [ -f "$PID_FILE" ]; then
    rm "$PID_FILE"
    echo "Removed stale PID file."
else
    echo "No PID file to clean."
fi
