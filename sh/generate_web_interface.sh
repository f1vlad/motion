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
    VIDEO_PLAYERS+="            <div class=\"cctv-panel\">\n"
    VIDEO_PLAYERS+="                <video id=\"video-${STREAM}\" class=\"video-js vjs-default-skin\" controls preload=\"auto\" autoplay muted playsinline "
    VIDEO_PLAYERS+="                    data-setup='{} '>\n"
    VIDEO_PLAYERS+="                    <source src=\"http://localhost:8888/${STREAM}/index.m3u8\" type=\"application/x-mpegURL\">\n"
    VIDEO_PLAYERS+="                </video>\n"
    VIDEO_PLAYERS+="                <div class=\"panel-overlay\"><span class=\"timestamp\">${STREAM}</span></div>\n"
    VIDEO_PLAYERS+="            </div>"
done

# Video.js and HLS.js script block
VIDEOJS_SCRIPT=""
VIDEOJS_SCRIPT+="    <script src=\"https://vjs.zencdn.net/7.11.4/video.min.js\"></script>\n"
VIDEOJS_SCRIPT+="    <script src=\"https://unpkg.com/@videojs/http-streaming@2.13.0/dist/videojs-http-streaming.min.js\"></script>\n"
VIDEOJS_SCRIPT+="    <script>\n"
VIDEOJS_SCRIPT+="        document.addEventListener('DOMContentLoaded', function() {\n"
VIDEOJS_SCRIPT+="            const videoElements = document.querySelectorAll('video');\n"
VIDEOJS_SCRIPT+="            videoElements.forEach(video => {\n"
VIDEOJS_SCRIPT+="                const player = videojs(video.id);\n"
VIDEOJS_SCRIPT+="                player.ready(function() {\n"
VIDEOJS_SCRIPT+="                    this.play().catch(error => {\n"
VIDEOJS_SCRIPT+="                        console.log('Autoplay prevented:', error);\n"
VIDEOJS_SCRIPT+="                    });\n"
VIDEOJS_SCRIPT+="                });\n"
VIDEOJS_SCRIPT+="            });\n"
VIDEOJS_SCRIPT+="        });\n"
VIDEOJS_SCRIPT+="    <\/script>\n"

# Use a "here document" to write the entire HTML file
cat <<EOF > "$OUTPUT_HTML"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Futuristic Surveillance UI</title>
    <link rel="stylesheet" href="style.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&family=VT323&display=swap" rel="stylesheet">
</head>
<body>
    <div class="fui-container">
        <header class="fui-header">
            <div class="header-left">
                <div class="icon-group">
                    <div class="icon-placeholder"></div>
                    <div class="icon-placeholder"></div>
                    <div class="icon-placeholder"></div>
                    <div class="icon-placeholder"></div>
                </div>
                <div class="icon-group">
                    <div class="icon-placeholder"></div>
                    <div class="icon-placeholder"></div>
                    <div class="icon-placeholder"></div>
                </div>
            </div>
            <div class="header-right">
                <div class="header-deco"></div>
            </div>
        </header>

        <aside class="fui-left-panel">
            <div class="panel-module calendar-module">
                <div class="panel-header">
                    <span>05/06/2017</span>
                    <span class="close-icon">×</span>
                </div>
                <div class="calendar">
                    <div class="day-header">01</div><div class="day-header">02</div><div class="day-header">03</div><div class="day-header">04</div><div class="day-header">05</div><div class="day-header">06</div><div class="day-header">07</div>
                    <div class="day">01</div><div class="day">02</div><div class="day">03</div><div class="day">04</div><div class="day">05</div><div class="day">06</div><div class="day">07</div>
                    <div class="day">08</div><div class="day">09</div><div class="day">10</div><div class="day">11</div><div class="day">12</div><div class="day">13</div><div class="day">14</div>
                    <div class="day">15</div><div class="day">16</div><div class="day">17</div><div class="day">18</div><div class="day">19</div><div class="day">20</div><div class="day">21</div>
                    <div class="day">22</div><div class="day">23</div><div class="day">24</div><div class="day">25</div><div class="day">26</div><div class="day">27</div><div class="day">28</div>
                    <div class="day">29</div><div class="day">30</div><div class="day">31</div>
                    <div class="day active-day">01</div><div class="day active-day">02</div><div class="day active-day">03</div><div class="day active-day">04</div><div class="day active-day">05</div>
                    <div class="day">06</div><div class="day">07</div><div class="day">08</div><div class="day">09</div><div class="day">10</div>
                </div>
            </div>
            <div class="panel-module dial-module">
                <div class="panel-header">
                    <span>TARGET_FOCUS: CHARLES</span>
                    <span class="close-icon">×</span>
                </div>
                <div class="dial-container">
                    <div class="dial-ring ring-1"></div>
                    <div class="dial-ring ring-2"></div>
                    <div class="dial-ring ring-3"></div>
                    <div class="crosshair"></div>
                    <div class="target top-left"></div>
                    <div class="target top-right"></div>
                    <div class="target bottom-left"></div>
                    <div class="target bottom-right"></div>
                </div>
                <div class="dial-controls">
                    <div class="dial-knob"></div>
                    <div class="dial-slider"></div>
                    <div class="dial-knob"></div>
                </div>
            </div>
            <div class="panel-module switches-module">
                <div class="switch-row">
                    <div class="switch"></div><div class="switch"></div><div class="switch active"></div><div class="switch"></div>
                    <div class="switch"></div><div class="switch"></div><div class="switch"></div><div class="switch"></div>
                </div>
                <div class="knob-row">
                    <div class="knob"></div>
                    <div class="knob"></div>
                    <div class="knob"></div>
                </div>
            </div>
        </aside>

        <main class="fui-main-content">
            ${VIDEO_PLAYERS}
        </main>

        <footer class="fui-footer-bar">
            <div class="footer-left">
                <div class="panel-module notes-module">
                    <div class="panel-header">
                        <span>NOTES</span>
                        <span class="rec-light">REC</span>
                    </div>
                    <div class="terminal-log">
                        <p>> AUTH: USER_CHARLES GRANTED</p>
                        <p>> REROUTING FEED_04 TO AUX_DISPLAY</p>
                        <p>> SYSTEM CHECK: ALL SYSTEMS NOMINAL</p>
                        <p>> TIMESTAMP_SYNC: 20170605-000300</p>
                        <p>> ALERT: MOTION DETECTED SECTOR_GAMMA</p>
                        <p>> LOGGING EVENT ID: 8492-A</p>
                    </div>
                </div>
                <div class="panel-module action-module">
                    <div class="panel-header"><span>ACTION</span></div>
                    <div class="action-buttons">
                        <div class="action-btn"></div>
                        <div class="action-btn"></div>
                        <div class="action-btn"></div>
                        <div class="action-btn"></div>
                    </div>
                </div>
            </div>
            <div class="footer-right">
                <div class="timeline-controls">
                    <span>00:03:00</span>
                    <div class="timeline-buttons">
                        <button class="fui-button">PAUSE</button>
                        <button class="fui-button">BACKUP</button>
                        <button class="fui-button">PROJECT</button>
                    </div>
                    <span>CUSTOM</span>
                </div>
                <div class="visualizer">
                    <div class="visualizer-grid"></div>
                    <div class="visualizer-data">
                        <div class="data-block"></div>
                        <div class="data-block"></div>
                    </div>
                    <div class="visualizer-label">K95</div>
                    <div class="visualizer-bars">
                        <div class="bar" style="height: 40%"></div><div class="bar" style="height: 60%"></div><div class="bar" style="height: 80%"></div>
                        <div class="bar" style="height: 50%"></div><div class="bar" style="height: 70%"></div><div class="bar" style="height: 90%"></div>
                        <div class="bar" style="height: 100%"></div><div class="bar" style="height: 85%"></div><div class="bar" style="height: 75%"></div>
                        <div class="bar" style="height: 60%"></div><div class="bar" style="height: 45%"></div><div class="bar" style="height: 30%"></div>
                    </div>
                    <div class="timeline-slider"></div>
                </div>
            </div>
        </footer>
    </div>
    ${VIDEOJS_SCRIPT}
</body>
</html>
EOF

echo "Generated $OUTPUT_HTML with new design."