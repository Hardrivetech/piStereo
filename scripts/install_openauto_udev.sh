#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RULE_SRC="$REPO_ROOT/udev/99-openauto-phone.rules"
DST="/etc/udev/rules.d/99-openauto-phone.rules"
STATE_DIR="/etc/pi_headunit"
STATE_FILE="$STATE_DIR/openauto_udev.state"

if [ ! -f "$RULE_SRC" ]; then
  echo "Rule file not found: $RULE_SRC" >&2
  exit 1
fi

sudo cp "$RULE_SRC" "$DST"
sudo udevadm control --reload
sudo udevadm trigger

# Record previous state of openauto-monitor.service (if present)
MONITOR_EXISTS=0
MONITOR_WAS_ENABLED=0
if systemctl list-unit-files | grep -q '^openauto-monitor.service'; then
  MONITOR_EXISTS=1
  if systemctl is-enabled --quiet openauto-monitor.service 2>/dev/null; then
    MONITOR_WAS_ENABLED=1
  fi
fi

sudo mkdir -p "$STATE_DIR"
sudo bash -c "cat > '$STATE_FILE' <<'EOF'
installed_rule=$DST
installed_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
monitor_exists=$MONITOR_EXISTS
monitor_was_enabled=$MONITOR_WAS_ENABLED
EOF"

if [ "$MONITOR_EXISTS" -eq 1 ] && [ "$MONITOR_WAS_ENABLED" -eq 1 ]; then
  echo "Disabling openauto-monitor.service to avoid duplicate behavior (was enabled)"
  sudo systemctl stop openauto-monitor.service || true
  sudo systemctl disable openauto-monitor.service || true
else
  if [ "$MONITOR_EXISTS" -eq 1 ]; then
    echo "openauto-monitor.service exists but was not enabled; leaving it disabled"
  else
    echo "openauto-monitor.service not present"
  fi
fi

echo "Installed udev rule to $DST (state recorded in $STATE_FILE)"
