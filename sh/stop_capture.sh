#!/bin/bash

CAPTURE_DIR="capture"

if [ -d "$CAPTURE_DIR" ]; then
    PID_FILES=$(find "$CAPTURE_DIR" -name "*.pid")

    if [ -z "$PID_FILES" ]; then
        echo "No active captures found (no .pid files in $CAPTURE_DIR)."
        exit 0
    fi

    for PID_FILE in $PID_FILES; do
        PID=$(cat "$PID_FILE" | tr -d '\n')
        if [ -n "$PID" ]; then
            echo "Stopping video capture for $(basename "$PID_FILE" .pid) (PID: $PID)..."
            kill -9 $PID
            rm "$PID_FILE"
            echo "Capture stopped."
        else
            echo "Error: PID file exists but is empty. Removing stale PID file: $PID_FILE"
            rm "$PID_FILE"
        fi
    done
else
    echo "Error: Capture directory not found: $CAPTURE_DIR"
fi
