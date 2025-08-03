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
    # Use HLS stream instead of RTSP since HLS is working correctly
    HLS_URL="http://localhost:8888/${STREAM_NAME}/index.m3u8"

    if [ -n "$HLS_URL" ]; then
        PID_FILE="$CAPTURE_DIR/${STREAM_NAME}.pid"

        # Create a wrapper script for continuous recording using HLS
        cat > "$CAPTURE_DIR/${STREAM_NAME}_recorder.sh" << 'EOF'
#!/bin/bash
STREAM_NAME="$1"
HLS_URL="$2"
CAPTURE_DIR="$3"

while true; do
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    OUTPUT_FILE="$CAPTURE_DIR/${STREAM_NAME}-${TIMESTAMP}.mp4"
    
    echo "Starting capture for ${STREAM_NAME} at ${TIMESTAMP}"
    
    # Use a simpler approach: capture shorter segments to avoid interruption
    if ffmpeg -i "$HLS_URL" -c copy -f mp4 -t 60 -movflags +faststart -y "$OUTPUT_FILE"; then
        # Check if the file was created successfully and is valid
        if [ -f "$OUTPUT_FILE" ] && [ $(stat -f%z "$OUTPUT_FILE") -gt 10000 ]; then
            # Verify the file is a valid MP4
            if ffprobe -v error "$OUTPUT_FILE" >/dev/null 2>&1; then
                echo "Successfully completed capture for ${STREAM_NAME}: ${OUTPUT_FILE}"
            else
                echo "File created but invalid MP4 for ${STREAM_NAME}, removing..."
                rm -f "$OUTPUT_FILE"
            fi
        else
            echo "Failed to create valid file for ${STREAM_NAME}"
            rm -f "$OUTPUT_FILE"
        fi
    else
        echo "ffmpeg failed for ${STREAM_NAME}"
        rm -f "$OUTPUT_FILE"
    fi
    
    sleep 1
done
EOF

        chmod +x "$CAPTURE_DIR/${STREAM_NAME}_recorder.sh"
        
        # Start the wrapper script
        nohup "$CAPTURE_DIR/${STREAM_NAME}_recorder.sh" "$STREAM_NAME" "$HLS_URL" "$CAPTURE_DIR" > "$CAPTURE_DIR/${STREAM_NAME}.log" 2>&1 & echo $! > "$PID_FILE"

        echo "Capture started for ${STREAM_NAME} in the background. PID: $(cat "$PID_FILE")"
    else
        echo "Could not find HLS URL for stream: ${STREAM_NAME}"
    fi
done
