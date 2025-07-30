#!/bin/bash
set -x

NUM_STREAMS=${1:-1} # Default to 1 stream if no argument is provided

# List of available ffmpeg lavfi video sources
SOURCES=(
    "testsrc=s=640x480:r=30"
    "mandelbrot=s=640x480:r=30"
    "smptebars=s=640x480:r=30"
    "smptehdbars=s=640x480:r=30"
    "cellauto=s=640x480:r=30"
    "life=s=640x480:r=30"
    "pal75bars=s=640x480:r=30"
    "pal100bars=s=640x480:r=30"
)

# Path to the mediamtx.yml file
MEDIAMTX_YML="rtsp-dev-server/mediamtx.yml"

# Start building the YAML content
YAML_CONTENT="paths:\n"

for i in $(seq 1 $NUM_STREAMS); do
    # Randomly select one source
    RANDOM_INDEX=$(( RANDOM % ${#SOURCES[@]} ))
    SELECTED_SOURCE=${SOURCES[$RANDOM_INDEX]}

    STREAM_NAME="stream_${i}"
    FFMPEG_CMD="ffmpeg -re -stream_loop -1 -f lavfi -i ${SELECTED_SOURCE} -c:v libx264 -preset ultrafast -tune zerolatency -f rtsp rtsp://localhost:8554/${STREAM_NAME}"

    YAML_CONTENT+="\n  ${STREAM_NAME}:\n"
    YAML_CONTENT+="    runOnDemand: ${FFMPEG_CMD}\n"
done

# Write the generated YAML content to the file
echo -e "$YAML_CONTENT" > "$MEDIAMTX_YML"

echo "Generated $MEDIAMTX_YML with ${NUM_STREAMS} random streams."