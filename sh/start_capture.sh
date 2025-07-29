#!/bin/bash
set -x

source "$(dirname "$0")"/config.sh

mkdir -p $CAPTURE_DIR

nohup ffmpeg \
    -rtsp_transport tcp \
    -i "$RTSP_URL" \
    -c copy \
    -f segment \
    -segment_time 360 \
    -strftime 1 \
    "$CAPTURE_DIR/${STREAM_NAME}-%Y%m%d-%H%M%S.mp4" > /dev/null 2>&1 & echo $! > $PID_FILE

echo "Capture started in the background. PID: $(cat $PID_FILE)"
