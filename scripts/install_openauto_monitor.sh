#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PREFIX=/opt/pi_headunit
sudo mkdir -p "$PREFIX/bin"
sudo cp "$REPO_ROOT/src/openauto_monitor.py" "$PREFIX/bin/openauto_monitor.py"
sudo chmod +x "$PREFIX/bin/openauto_monitor.py"
sudo mkdir -p /etc/pi_headunit
sudo cp "$REPO_ROOT/config/openauto.conf" /etc/pi_headunit/openauto.conf
sudo cp "$REPO_ROOT/systemd/openauto-monitor.service" /etc/systemd/system/openauto-monitor.service
sudo systemctl daemon-reload
sudo systemctl enable --now openauto-monitor.service
echo "Installed openauto-monitor and started service"
