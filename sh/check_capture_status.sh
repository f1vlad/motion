#!/bin/bash
set -x

CAPTURE_DIR="capture"

if [ -d "$CAPTURE_DIR" ]; then
    PID_FILES=$(find "$CAPTURE_DIR" -name "*.pid")

    if [ -z "$PID_FILES" ]; then
        echo "No active captures found (no .pid files in $CAPTURE_DIR)."
        exit 0
    fi

    for PID_FILE in $PID_FILES; do
        PID=$(cat "$PID_FILE" | tr -d '\n')
        STREAM_NAME=$(basename "$PID_FILE" .pid)
        if [ -n "$PID" ] && pgrep -l ffmpeg | grep -q "^$PID "; then
            echo "Capture for ${STREAM_NAME} is running. PID: $PID"
        else
            echo "Error: Capture for ${STREAM_NAME} is not running, but PID file exists. Stale PID file?"
        fi
    done
else
    echo "Error: Capture directory not found: $CAPTURE_DIR"
fi
