SHELL := /usr/bin/env bash

.PHONY: install uninstall status scan-now edit-config logs reload-systemd apply-audio-fix uninstall-audio-fix help

help:
	@echo "Targets:"
	@echo "  make apply-audio-fix     - Apply the audio buzzing fix"
	@echo "  make uninstall-audio-fix - Remove the fix"
	@echo "  make install               - install clam av and fix audio"
	@echo "  make dark-mode             - set up darkmode for GTK"
	@echo "  make help                  - Show help"

install:
	@echo "==> Installing and configuring ClamAV (requires sudo)..."
	sudo bash bin/install-clamav.sh
	@echo "==> Installing and configuring audio fix (requires sudo)..."
	sudo bash bin/apply-audio-fix.sh

uninstall:
	@echo "==> Uninstalling ClamAV setup (requires sudo)..."
	sudo bash bin/uninstall-clamav.sh
	@echo "==> Uninstalling audio fix (requires sudo)..."
	sudo bash bin/uninstall-audio-fix.sh


status:
	@echo "==> ClamAV-related service status:"
	@echo
	@systemctl status clamav-daemon.service --no-pager || true
	@echo
	@systemctl status clamav-freshclam-once.timer --no-pager || true
	@echo
	@systemctl status clamav-periodic-scan.timer --no-pager || true
	@echo
	@systemctl status clamav-periodic-scan.service --no-pager || true

scan-now:
	@echo "==> Triggering an immediate periodic scan (requires sudo)..."
	sudo systemctl start clamav-periodic-scan.service
	@echo "Scan started; check logs with: make logs"

edit-config:
	@echo "==> Opening periodic scan config (paths to scan)..."
	@echo "    You may be prompted for sudo to edit:"
	@sudo ${EDITOR:-nano} /etc/clamav/periodic-scan.conf

logs:
	@echo "==> Last 50 log lines for ClamAV services:"
	@sudo journalctl -u clamav-daemon.service \
	                 -u clamav-freshclam-once.service \
	                 -u clamav-freshclam-once.timer \
	                 -u clamav-periodic-scan.service \
	                 -u clamav-periodic-scan.timer \
	                 --no-pager -n 50 || true

reload-systemd:
	@echo "==> Reloading systemd daemon (requires sudo)..."
	sudo systemctl daemon-reload

apply-audio-fix:
	sudo bash bin/install-audio-fix.sh

uninstall-audio-fix:
	sudo bash bin/uninstall-audio-fix.sh

reload:
	sudo bash bin/reload-audio.sh

dark-mode:
	sudo bash bin/install-dark-mode.sh
