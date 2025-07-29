.PHONY: start-capture stop-capture status-capture clean-pid

start-capture:
	@echo "Starting video capture..."
	@/bin/bash -c "$(CURDIR)/sh/start_capture.sh"

stop-capture:
	@/bin/bash -c "$(CURDIR)/sh/stop_capture.sh"

status-capture:
	@/bin/bash -c "$(CURDIR)/sh/check_capture_status.sh"

clean-pid:
	@/bin/bash -c "$(CURDIR)/sh/clean_pid.sh"	