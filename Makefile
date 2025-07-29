.PHONY: start-capture stop-capture status-capture clean-pid

# Directory to store video captures and the PID file
CAPTURE_DIR := capture
PID_FILE := $(CAPTURE_DIR)/ffmpeg.pid

start-capture:
	@echo "Starting video capture..."
	@./sh/start_capture.sh

stop-capture:
	@./sh/stop_capture.sh

status-capture:
	@./sh/check_capture_status.sh

clean-pid:
	@./sh/clean_pid.sh	