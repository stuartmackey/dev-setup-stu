#!/usr/bin/env bash
set -euo pipefail

# ClamAV configuration for Arch Linux
# - Configures freshclam & clamd
# - Enables system-wide services
# - Sets up daily automatic scans via systemd timer
#
# After running:
#   - Virus definitions auto-update (clamav-freshclam-once.timer)
#   - clamd server runs at boot (clamav-daemon.service)
#   - Daily scans of /home (configurable in /etc/clamav/periodic-scan.conf)

if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root, e.g.: sudo $0"
  exit 1
fi

if ! command -v clamconf >/dev/null 2>&1; then
  echo "ClamAV is not installed or not in PATH."
  echo "Install ClamAV first by running:"
  echo "  sudo bash bin/install-clamav.sh"
  echo "or"
  echo "  make install-clamav"
  exit 1
fi

echo "==> Ensuring ClamAV config files exist..."
if [[ ! -f /etc/clamav/freshclam.conf ]]; then
  echo "    Generating /etc/clamav/freshclam.conf..."
  clamconf -g freshclam.conf >/etc/clamav/freshclam.conf
fi

if [[ ! -f /etc/clamav/clamd.conf ]]; then
  echo "    Generating /etc/clamav/clamd.conf..."
  clamconf -g clamd.conf >/etc/clamav/clamd.conf
fi

echo "==> Disabling 'Example' safety guard in configs (if present)..."
for cfg in /etc/clamav/freshclam.conf /etc/clamav/clamd.conf; do
  if [[ -f "$cfg" ]]; then
    sed -i 's/^[[:space:]]*Example$/#Example/' "$cfg"
  fi
done

echo "==> Ensuring ClamAV log directory and freshclam.log exist..."
install -d -m 750 -o clamav -g clamav /var/log/clamav
touch /var/log/clamav/freshclam.log
chown clamav:clamav /var/log/clamav/freshclam.log
chmod 600 /var/log/clamav/freshclam.log

echo "==> Ensuring ClamAV DB directory ownership..."
install -d -m 750 -o clamav -g clamav /var/lib/clamav
chown -R clamav:clamav /var/lib/clamav

echo "==> Running initial virus definition update (freshclam)..."
freshclam

echo "==> Enabling automatic virus definition updates (clamav-freshclam-once.timer)..."
systemctl enable --now clamav-freshclam-once.timer || {
  # Fallback if only service exists
  systemctl enable --now clamav-freshclam.service || true
}

echo "==> Enabling system-wide ClamAV daemon (clamav-daemon.service)..."
systemctl enable --now clamav-daemon.service

###############################################################################
# PERIODIC SCANNING SETUP
###############################################################################

echo "==> Creating periodic scan configuration..."

SCAN_CONF="/etc/clamav/periodic-scan.conf"
SCAN_SCRIPT="/usr/local/sbin/clamav-periodic-scan.sh"
SCAN_SERVICE="/etc/systemd/system/clamav-periodic-scan.service"
SCAN_TIMER="/etc/systemd/system/clamav-periodic-scan.timer"
SCAN_LOG="/var/log/clamav/periodic-scan.log"

# Default paths to scan once per day. One path per line.
if [[ ! -f "$SCAN_CONF" ]]; then
  cat >"$SCAN_CONF" <<'EOF'
# Paths to scan periodically with ClamAV
# One path per line, comments starting with # are ignored.

#/    # WARNING: scanning the whole filesystem can be very slow
/home
EOF
  echo "    Created $SCAN_CONF with default path: /home"
else
  echo "    $SCAN_CONF already exists, leaving as-is."
fi

echo "==> Creating periodic scan script: $SCAN_SCRIPT"
cat >"$SCAN_SCRIPT" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

CONF="/etc/clamav/periodic-scan.conf"
LOG="/var/log/clamav/periodic-scan.log"

# Pick scanner: prefer clamdscan (daemon), fallback to clamscan
SCANNER="clamdscan"
if ! command -v clamdscan >/dev/null 2>&1 || ! systemctl is-active --quiet clamav-daemon.service; then
  SCANNER="clamscan"
fi

if [[ ! -f "$CONF" ]]; then
  echo "$(date -Is) [clamav-periodic-scan] No config file at $CONF; aborting." >> "$LOG"
  exit 0
fi

paths=()
while IFS= read -r line; do
  # skip empty or commented lines
  [[ -z "${line}" || "${line}" =~ ^[[:space:]]*# ]] && continue
  paths+=("${line}")
done < "$CONF"

if ((${#paths[@]} == 0)); then
  echo "$(date -Is) [clamav-periodic-scan] No paths defined in $CONF; nothing to scan." >> "$LOG"
  exit 0
fi

mkdir -p "$(dirname "$LOG")"
touch "$LOG"

echo "==== $(date -Is) [clamav-periodic-scan] Starting scan with $SCANNER on: ${paths[*]} ====" >> "$LOG"

if [[ "$SCANNER" == "clamdscan" ]]; then
  # Use fdpass so clamd can inspect root-owned files when this script runs as root
  "$SCANNER" --fdpass --multiscan --infected --log="$LOG" "${paths[@]}"
else
  "$SCANNER" --recursive --infected --log="$LOG" "${paths[@]}"
fi

echo "==== $(date -Is) [clamav-periodic-scan] Scan finished ====" >> "$LOG"
EOF

chmod 750 "$SCAN_SCRIPT"
chown root:root "$SCAN_SCRIPT"

echo "==> Creating systemd service for periodic scan: $SCAN_SERVICE"
cat >"$SCAN_SERVICE" <<EOF
[Unit]
Description=Periodic ClamAV scan of configured paths
Documentation=man:clamscan(1) man:clamdscan(1)
After=network.target clamav-daemon.service

[Service]
Type=oneshot
ExecStart=$SCAN_SCRIPT
Nice=10
IOSchedulingClass=best-effort
IOSchedulingPriority=7
EOF

echo "==> Creating systemd timer for periodic scan: $SCAN_TIMER"
cat >"$SCAN_TIMER" <<EOF
[Unit]
Description=Run ClamAV periodic scan once daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

echo "==> Reloading systemd units and enabling periodic scan timer..."
systemctl daemon-reload
systemctl enable --now clamav-periodic-scan.timer

echo
echo "============================================================================="
echo "ClamAV configuration complete."
echo
echo "What is now configured:"
echo "  - clamav-daemon.service          : ClamAV server (clamd) running for all users"
echo "  - clamav-freshclam-once.timer    : Daily virus definition updates"
echo "  - clamav-periodic-scan.timer     : Daily automatic scans (default: /home)"
echo
echo "To adjust what gets scanned daily, edit:"
echo "  $SCAN_CONF"
echo "and then run:"
echo "  systemctl restart clamav-periodic-scan.timer"
echo
echo "You can also trigger an immediate scan with:"
echo "  systemctl start clamav-periodic-scan.service"
echo "============================================================================="
