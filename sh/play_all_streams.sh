#!/bin/bash

MEDIAMTX_YML="rtsp-dev-server/mediamtx.yml"

if [ ! -f "$MEDIAMTX_YML" ]; then
    echo "Error: $MEDIAMTX_YML not found. Please start the dev server first." >&2
    exit 1
fi

# Extract stream names from mediamtx.yml
# Looks for lines like '  stream_X:'
STREAM_NAMES=$(grep -oE '^[[:space:]]*stream_[0-9]+:' "$MEDIAMTX_YML" | sed 's/^[[:space:]]*//; s/:$//')

if [ -z "$STREAM_NAMES" ]; then
    echo "No streams found in $MEDIAMTX_YML." >&2
    exit 0
fi

echo "Playing the following streams:"
for STREAM in $STREAM_NAMES; do
    echo "- rtsp://localhost:8554/${STREAM}"
    ffplay -rtsp_transport tcp "rtsp://localhost:8554/${STREAM}" > /dev/null 2>&1 &
done

echo "All streams launched in the background."
