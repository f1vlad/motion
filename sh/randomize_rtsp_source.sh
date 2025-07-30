#!/bin/bash
set -x

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

# Randomly select one source
RANDOM_INDEX=$(( RANDOM % ${#SOURCES[@]} ))
SELECTED_SOURCE=${SOURCES[$RANDOM_INDEX]}

# Construct the full ffmpeg command
FFMPEG_CMD="ffmpeg -re -stream_loop -1 -f lavfi -i ${SELECTED_SOURCE} -c:v libx264 -preset ultrafast -tune zerolatency -f rtsp rtsp://localhost:8554/stream"

# Path to the mediamtx.yml file
MEDIAMTX_YML="rtsp-dev-server/mediamtx.yml"

# Read the content of the file
FILE_CONTENT=$(cat "$MEDIAMTX_YML")

# Comment out all existing runOnDemand lines within the stream path
UPDATED_CONTENT=$(echo "$FILE_CONTENT" | awk '/paths:/ {in_paths=1} /stream:/ {in_stream=1} /^[[:space:]]*[^#]*runOnDemand:/ {if (in_paths && in_stream) print "#" $$0; else print $$0; next} {print}')

# Find the line after 'stream:' and insert the new runOnDemand line
INSERT_LINE="    runOnDemand: ${FFMPEG_CMD}"
FINAL_CONTENT=$(echo "$UPDATED_CONTENT" | awk -v insert="$INSERT_LINE" '/stream:/ {print; print insert; inserted=1; next} {print}')

# Write the modified content back to the file
echo "$FINAL_CONTENT" > "$MEDIAMTX_YML"

echo "Updated $MEDIAMTX_YML with random source: ${SELECTED_SOURCE}"
