#!/bin/bash

# Find all ffplay processes connected to localhost:8554 and kill them
# Use pgrep to find PIDs of ffplay processes
# Then filter by command line arguments to ensure we only kill our streams

PIDS=$(pgrep -f "ffplay -rtsp_transport tcp rtsp://localhost:8554/")

if [ -z "$PIDS" ]; then
    echo "No ffplay streams found to stop."
else
    echo "Stopping ffplay streams with PIDs: $PIDS"
    kill $PIDS
    echo "All ffplay streams stopped."
fi
