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
HTML_CONTENT+="        body { font-family: sans-serif; margin: 20px; background-color: #f0f0f0; }\n"
HTML_CONTENT+="        .video-container { display: flex; flex-wrap: wrap; gap: 20px; justify-content: center; }\n"
HTML_CONTENT+="        .video-item { background-color: #fff; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }\n"
HTML_CONTENT+="        .video-js { width: 640px; height: 480px; }\n"
HTML_CONTENT+="        h2 { text-align: center; color: #333; }\n"
HTML_CONTENT+="    </style>\n"
HTML_CONTENT+="</head>\n"
HTML_CONTENT+="<body>\n"
HTML_CONTENT+="    <h1>Live RTSP Streams</h1>\n"
HTML_CONTENT+="    <div class=\"video-container\">\n"

# Add video players for each stream
for STREAM in $STREAM_NAMES; do
    HTML_CONTENT+="        <div class=\"video-item\">\n"
    HTML_CONTENT+="            <h2>${STREAM}</h2>\n"
    HTML_CONTENT+="            <video id=\"video-${STREAM}\" class=\"video-js vjs-default-skin\" controls preload=\"auto\"\n"
    HTML_CONTENT+="                data-setup='{} '>\n"
    HTML_CONTENT+="                <source src="http://localhost:8888/${STREAM}/index.m3u8" type="application/x-mpegURL">"
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
