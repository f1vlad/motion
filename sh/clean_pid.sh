#!/bin/bash

CAPTURE_DIR="capture"

if [ -d "$CAPTURE_DIR" ]; then
    PID_FILES=$(find "$CAPTURE_DIR" -name "*.pid")

    if [ -z "$PID_FILES" ]; then
        echo "No PID files to clean."
        exit 0
    fi

    for PID_FILE in $PID_FILES; do
        rm "$PID_FILE"
        echo "Removed stale PID file: $PID_FILE"
    done
else
    echo "Error: Capture directory not found: $CAPTURE_DIR"
fi