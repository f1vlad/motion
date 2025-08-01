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

# Construct the video player HTML for each stream
VIDEO_PLAYERS=""
for STREAM in $STREAM_NAMES; do
    VIDEO_PLAYERS+="            <div class=\"cctv-panel\">"
    VIDEO_PLAYERS+="                <video id=\"video-${STREAM}\" class=\"video-js vjs-default-skin\" controls preload=\"auto\" autoplay muted playsinline "
    VIDEO_PLAYERS+="                    data-setup='{} '>"
    VIDEO_PLAYERS+="                    <source src=\"http://localhost:8888/${STREAM}/index.m3u8\" type=\"application/x-mpegURL\">"
    VIDEO_PLAYERS+="                </video>"
    VIDEO_PLAYERS+="                <div class=\"panel-overlay\"><span class=\"timestamp\">${STREAM}</span></div>"
    VIDEO_PLAYERS+="            </div>"
done

# Video.js and HLS.js script block
VIDEOJS_SCRIPT=""
VIDEOJS_SCRIPT+="    <script src=\"https://vjs.zencdn.net/7.11.4/video.min.js\"></script>"
VIDEOJS_SCRIPT+="    <script src=\"https://unpkg.com/@videojs/http-streaming@2.13.0/dist/videojs-http-streaming.min.js\"></script>"
VIDEOJS_SCRIPT+="    <script>"
VIDEOJS_SCRIPT+="        document.addEventListener('DOMContentLoaded', function() {"
VIDEOJS_SCRIPT+="            const videoElements = document.querySelectorAll('video');"
VIDEOJS_SCRIPT+="            videoElements.forEach(video => {"
VIDEOJS_SCRIPT+="                const player = videojs(video.id);"
VIDEOJS_SCRIPT+="                player.ready(function() {"
VIDEOJS_SCRIPT+="                    this.play().catch(error => {"
VIDEOJS_SCRIPT+="                        console.log('Autoplay prevented:', error);"
VIDEOJS_SCRIPT+="                    });"
VIDEOJS_SCRIPT+="                });"
VIDEOJS_SCRIPT+="            });"
VIDEOJS_SCRIPT+="        });"
VIDEOJS_SCRIPT+="    <\/script>"

# Use a "here document" to write the entire HTML file
cat <<EOF > "$OUTPUT_HTML"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Surveillance UI</title>
    <link rel="stylesheet" href="style.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&family=VT323&display=swap" rel="stylesheet">
</head>
<body>
    <div class="fui-container">
        <header class="fui-header">
            <div class="header-left">
                <div class="panel-header">
                        <span>SYS</span>
                        <span class="rec-light">REC</span>
                    </div>
                <div class="icon-group">
                    <div class="day">95</div>
                    <div class="day">32</div>
                    <div class="day">56</div>
                </div>
            </div>
            <div class="header-right">
                <div class="header-deco">
                    <div class="terminal-log">
                        <p>&gt; AUTH: ROOT GRANTED</p>
                        <p>&gt; REROUTING FEED_04 TO AUX_DISPLAY</p>
                        <p>&gt; SYSTEM CHECK: ALL SYSTEMS NOMINAL</p>
                        <p>&gt; TIMESTAMP_SYNC: 20170605-000300</p>
                        <p>&gt; ALERT: MOTION DETECTED SECTOR_GAMMA</p>
                        <p>&gt; LOGGING EVENT ID: 8492-A</p>
                    </div>
                </div>
            </div>
        </header>


        <main class="fui-main-content">
            ${VIDEO_PLAYERS}
        </main>


    </div>
    ${VIDEOJS_SCRIPT}
</body>
</html>
EOF

echo "Generated $OUTPUT_HTML with new design."