#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DST="/etc/udev/rules.d/99-openauto-phone.rules"
BACKUP_DST="/etc/udev/rules.d/99-openauto-phone.rules.bak"
STATE_FILE="/etc/pi_headunit/openauto_udev.state"

if [ -f "$DST" ]; then
  echo "Removing $DST -> $BACKUP_DST"
  sudo mv "$DST" "$BACKUP_DST"
  sudo udevadm control --reload
  sudo udevadm trigger
  echo "Udev rule removed and udev reloaded"
else
  echo "No udev rule at $DST"
fi

# Restore polling monitor state if the installer recorded it
if [ -f "$STATE_FILE" ]; then
  MONITOR_WAS_ENABLED=$(grep '^monitor_was_enabled=' "$STATE_FILE" | cut -d'=' -f2 || echo 0)
  if [ "$MONITOR_WAS_ENABLED" = "1" ] || [ "$MONITOR_WAS_ENABLED" = "true" ]; then
    echo "Re-enabling openauto-monitor.service (was enabled before installer)"
    sudo systemctl enable --now openauto-monitor.service || true
  else
    echo "Not re-enabling openauto-monitor.service (it was not enabled before installer)"
  fi
  sudo rm -f "$STATE_FILE"
else
  echo "No state file at $STATE_FILE; not changing monitor state"
fi

echo "Uninstall complete. Backup rule file at $BACKUP_DST"
