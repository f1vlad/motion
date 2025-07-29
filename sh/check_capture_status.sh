#!/bin/bash
set -x

source "$(dirname "$0")"/config.sh

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE" | tr -d '\n')
    if [ -n "$PID" ] && pgrep -l ffmpeg | grep -q "^$PID "; then
        echo "Capture is running. PID: $PID"
    else
        echo "Error: Capture is not running, but PID file exists. Stale PID file?"
    fi
else
    echo "Capture is not running."
fi
