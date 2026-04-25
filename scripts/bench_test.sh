#!/usr/bin/env bash
# bench_test.sh — safe bench checks for piStereo (no external hardware required)
# Usage: sudo bash scripts/bench_test.sh [output_file]

OUT=${1:-/tmp/pi_bench_report_$(date +%Y%m%d_%H%M%S).txt}

# Helper: log header
h() { echo "\n===== $* =====\n" >> "$OUT"; }
# Helper: run a command if present, capture output
run_cmd() {
  cmd="$1"
  shift
  echo "> $cmd $*" >> "$OUT"
  if command -v "$cmd" >/dev/null 2>&1; then
    "$cmd" "$@" >> "$OUT" 2>&1 || echo "[command exited with non-zero status]" >> "$OUT"
  else
    echo "[not installed: $cmd]" >> "$OUT"
  fi
  echo >> "$OUT"
}

# Start report
echo "piStereo bench test report" > "$OUT"
echo "Generated: $(date -u)" >> "$OUT"
uname -a >> "$OUT" 2>&1 || true
echo >> "$OUT"

# System
h "System Info"
if [ -f /etc/os-release ]; then cat /etc/os-release >> "$OUT" 2>&1; fi
run_cmd uname -a
run_cmd uptime
run_cmd whoami
run_cmd id
run_cmd date
run_cmd cat /proc/cpuinfo
run_cmd lsblk -f
run_cmd df -h /
run_cmd free -h

# Network
h "Network"
run_cmd ip -4 addr
run_cmd ip route
run_cmd ss -tuln || run_cmd netstat -tuln
# quick ping test
if command -v ping >/dev/null 2>&1; then
  echo "> ping -c2 -W1 8.8.8.8" >> "$OUT"
  ping -c2 -W1 8.8.8.8 >> "$OUT" 2>&1 || echo "[ping failed or blocked]" >> "$OUT"
  echo >> "$OUT"
fi

# USB
h "USB Devices"
run_cmd lsusb

# Audio
h "Audio"
run_cmd aplay -l
if command -v pactl >/dev/null 2>&1; then
  pactl list short sinks >> "$OUT" 2>&1 || true
else
  echo "[pactl not installed]" >> "$OUT"
fi

# Bluetooth
h "Bluetooth"
if command -v bluetoothctl >/dev/null 2>&1; then
  bluetoothctl show >> "$OUT" 2>&1 || true
  echo >> "$OUT"
  bluetoothctl devices >> "$OUT" 2>&1 || true
else
  echo "[bluetoothctl not installed]" >> "$OUT"
fi

# Display
h "Display / Input"
if [ -d /sys/class/drm ]; then
  ls -la /sys/class/drm >> "$OUT" 2>&1 || true
fi
if command -v xinput >/dev/null 2>&1; then
  run_cmd xinput list
else
  echo "[xinput not installed or no X session]" >> "$OUT"
fi

# GPIO
h "GPIO"
if [ -d /sys/class/gpio ]; then
  ls -la /sys/class/gpio >> "$OUT" 2>&1 || true
else
  echo "[no /sys/class/gpio]" >> "$OUT"
fi
if command -v raspi-gpio >/dev/null 2>&1; then
  run_cmd raspi-gpio get
fi

# Services
h "Services"
run_cmd systemctl status pi_headunit_display.service --no-pager || true
run_cmd systemctl status openauto-monitor.service --no-pager || true
run_cmd systemctl status openauto.service --no-pager || true

# Logs (safe tail)
h "Kernel Logs (dmesg)"
run_cmd dmesg | tail -n 200

h "Journal (last 200 lines, may require sudo)"
if command -v journalctl >/dev/null 2>&1; then
  journalctl -b -n 200 -o short-iso >> "$OUT" 2>&1 || echo "[journalctl unavailable or permission denied]" >> "$OUT"
else
  echo "[journalctl not installed]" >> "$OUT"
fi

# Summary & path
echo "\nReport saved to: $OUT\n"
echo "piStereo bench test complete. View the report with: less $OUT" 
