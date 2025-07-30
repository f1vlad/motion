.PHONY: start-capture stop-capture status-capture clean-pid start-dev-server play-all-streams stop-all-streams list-all-rtsp-streams generate-web-interface serve-web-interface stop-web-interface

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
	@/bin/bash -c "$(CURDIR)/sh/randomize_rtsp_source.sh $(STREAMS)"
	@echo "Starting RTSP dev server..."
	@docker run -it --rm -p 8554:8554 -p 8888:8888 -v $(CURDIR)/rtsp-dev-server/mediamtx.yml:/mediamtx.yml bluenviron/mediamtx:latest-ffmpeg

play-all-rtsp-streams:
	@echo "Playing all streams..."
	@/bin/bash -c "$(CURDIR)/sh/play_all_streams.sh"

stop-all-rtsp-streams:
	@echo "Stopping all ffplay streams..."
	@/bin/bash -c "$(CURDIR)/sh/stop_all_streams.sh"

list-all-rtsp-streams:
	@echo "Listing all RTSP streams..."
	@/bin/bash -c "$(CURDIR)/sh/list_all_rtsp_streams.sh"

generate-web-interface:
	@echo "Generating web interface..."
	@/bin/bash -c "$(CURDIR)/sh/generate_web_interface.sh"

serve-web-interface:
	@echo "Starting web server on port 8000..."
	@python3 -m http.server 8000 > /dev/null 2>&1 &
	@echo "Web server started. Open http://localhost:8000 in your browser."

stop-web-interface:
	@echo "Stopping web server..."
	@/bin/bash -c "$(CURDIR)/sh/stop_web_interface.sh"	