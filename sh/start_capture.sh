#!/bin/bash
set -x

CAPTURE_DIR="capture"
mkdir -p $CAPTURE_DIR

MEDIAMTX_YML="rtsp-dev-server/mediamtx.yml"

if [ ! -f "$MEDIAMTX_YML" ]; then
    echo "Error: $MEDIAMTX_YML not found." >&2
    exit 1
fi

# Extract stream names and URLs
STREAM_NAMES=$(grep -oE '^[[:space:]]*stream_[0-9]+:' "$MEDIAMTX_YML" | sed 's/^[[:space:]]*//; s/:$//')

for STREAM_NAME in $STREAM_NAMES; do
    RTSP_URL=$(grep -A 1 "${STREAM_NAME}:" "$MEDIAMTX_YML" | grep 'runOnDemand' | sed -E 's/.*(rtsp:\/\/localhost:8554\/[^ ]+).*/\1/')

    if [ -n "$RTSP_URL" ]; then
        PID_FILE="$CAPTURE_DIR/${STREAM_NAME}.pid"

        nohup ffmpeg \
            -rtsp_transport tcp \
            -i "$RTSP_URL" \
            -c:v libx264 \
            -f segment \
            -segment_time 360 \
            -movflags +frag_keyframe+empty_moov \
            -strftime 1             "$CAPTURE_DIR/${STREAM_NAME}-%Y%m%d-%H%M%S.mp4" > "$CAPTURE_DIR/${STREAM_NAME}.log" 2>&1 & echo $! > "$PID_FILE"

        echo "Capture started for ${STREAM_NAME} in the background. PID: $(cat "$PID_FILE")"
    else
        echo "Could not find RTSP URL for stream: ${STREAM_NAME}"
    fi
done
