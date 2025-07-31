#!/bin/bash

MEDIAMTX_YML="rtsp-dev-server/mediamtx.yml"
OUTPUT_HTML="index.html"

if [ ! -f "$MEDIAMTX_YML" ]; then
    echo "Error: $MEDIAMTX_YML not found. Please start the dev server first." >&2
    exit 1
fi

# Extract stream names from mediamtx.yml
STREAM_NAMES=$(grep -oE '^[[:space:]]*stream_[0-9]+:' "$MEDIAMTX_YML" | sed 's/^[[:space:]]*//; s/:$//')

if [ -z "$STREAM_NAMES" ]; then
    echo "No streams found in $MEDIAMTX_YML. Cannot generate web interface." >&2
    exit 0
fi

# Start HTML content
HTML_CONTENT="<!DOCTYPE html>\n"
HTML_CONTENT+="<html lang=\"en\">\n"
HTML_CONTENT+="<head>\n"
HTML_CONTENT+="    <meta charset=\"UTF-8\">\n"
HTML_CONTENT+="    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n"
HTML_CONTENT+="    <title>RTSP Streams</title>\n"
HTML_CONTENT+="    <link href=\"https://vjs.zencdn.net/7.11.4/video-js.css\" rel=\"stylesheet\" />\n"
HTML_CONTENT+="    <style>\n"
HTML_CONTENT+="        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; margin: 0; background-color: #1a1a1a; color: #e0e0e0; }\n"
HTML_CONTENT+="        h1 { text-align: center; color: #00e676; padding: 20px; margin-bottom: 0; }\n"
HTML_CONTENT+="        .video-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 20px; padding: 20px; justify-content: center; }\n"
HTML_CONTENT+="        .video-card { background-color: #2c2c2c; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.5); display: flex; flex-direction: column; }\n"
HTML_CONTENT+="        .video-card-header { background-color: #3a3a3a; padding: 10px 15px; font-size: 1.1em; font-weight: bold; color: #00e676; border-bottom: 1px solid #444; }\n"
HTML_CONTENT+="        .video-js { width: 100% !important; height: auto !important; aspect-ratio: 16 / 9; }\n"
HTML_CONTENT+="        .video-js .vjs-control-bar { background-color: rgba(0,0,0,0.5); }\n"
HTML_CONTENT+="    </style>\n"
HTML_CONTENT+="</head>\n"
HTML_CONTENT+="<body>\n"
HTML_CONTENT+="    <h1>Live Stream Dashboard</h1>\n"
HTML_CONTENT+="    <div class=\"video-grid\">\n"

# Add video players for each stream
for STREAM in $STREAM_NAMES; do
    HTML_CONTENT+="        <div class=\"video-card\">\n"
    HTML_CONTENT+="            <div class=\"video-card-header\">${STREAM}</div>\n"
    HTML_CONTENT+="            <video id=\"video-${STREAM}\" class=\"video-js vjs-default-skin\" controls preload=\"auto\" autoplay muted playsinline\n"
    HTML_CONTENT+="                data-setup='{} '>\n"
    HTML_CONTENT+="                <source src=\"http://localhost:8888/${STREAM}/index.m3u8\" type=\"application/x-mpegURL\">\n"
    HTML_CONTENT+="            </video>\n"
    HTML_CONTENT+="        </div>\n"
done

# End HTML content and add video.js scripts
HTML_CONTENT+="    </div>\n"
HTML_CONTENT+="    <script src=\"https://vjs.zencdn.net/7.11.4/video.min.js\"></script>\n"
HTML_CONTENT+="    <script src=\"https://unpkg.com/@videojs/http-streaming@2.13.0/dist/videojs-http-streaming.min.js\"></script>\n"
HTML_CONTENT+="    <script>\n"
HTML_CONTENT+="        // Initialize all video.js players\n"
HTML_CONTENT+="        document.addEventListener('DOMContentLoaded', function() {\n"
HTML_CONTENT+="            const videoElements = document.querySelectorAll('video');\n"
HTML_CONTENT+="            videoElements.forEach(video => {\n"
HTML_CONTENT+="                videojs(video.id);\n"
HTML_CONTENT+="            });\n"
HTML_CONTENT+="        });\n"
HTML_CONTENT+="    </script>\n"
HTML_CONTENT+="</body>\n"
HTML_CONTENT+="</html>\n"

# Write to index.html
echo -e "$HTML_CONTENT" > "$OUTPUT_HTML"

echo "Generated $OUTPUT_HTML with links to all streams."