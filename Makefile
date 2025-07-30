.PHONY: start-capture stop-capture status-capture clean-pid start-dev-server

start-capture:
	@echo "Starting video capture..."
	@/bin/bash -c "$(CURDIR)/sh/start_capture.sh"

stop-capture:
	@/bin/bash -c "$(CURDIR)/sh/stop_capture.sh"

status-capture:
	@/bin/bash -c "$(CURDIR)/sh/check_capture_status.sh"

clean-pid:
	@/bin/bash -c "$(CURDIR)/sh/clean_pid.sh"

start-rtsp-server:
	@echo "Randomizing RTSP source..."
	@/bin/bash -c "$(CURDIR)/sh/randomize_rtsp_source.sh"
	@echo "Starting RTSP dev server..."
	@docker run -it --rm -p 8554:8554 -v $(CURDIR)/rtsp-dev-server/mediamtx.yml:/mediamtx.yml bluenviron/mediamtx:latest-ffmpeg	