#!/bin/bash

PIDS=$(ps aux | grep "http.server 8000" | grep -v grep | awk '{print $2}')

if [ -z "$PIDS" ]; then
    echo "No web server found running on port 8000."
else
    echo "Stopping web server with PIDs: $PIDS"
    kill $PIDS
    echo "Web server stopped."
fi
