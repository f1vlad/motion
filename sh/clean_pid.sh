#!/bin/bash

source "$(dirname "$0")"/config.sh

if [ -f "$PID_FILE" ]; then
    rm "$PID_FILE"
    echo "Removed stale PID file."
else
    echo "No PID file to clean."
fi