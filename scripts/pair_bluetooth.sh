#!/bin/bash
# Usage: sudo ./pair_bluetooth.sh AA:BB:CC:DD:EE:FF
if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root: sudo $0 <MAC>"
  exit 1
fi
if [ -z "$1" ]; then
  echo "Usage: sudo $0 <MAC_ADDRESS>"
  exit 1
fi
MAC=$1

cat <<EOF | bluetoothctl
power on
agent NoInputNoOutput
default-agent
scan on
pair $MAC
trust $MAC
connect $MAC
quit
EOF

echo "Pairing attempt finished. Check 'bluetoothctl' and 'pactl list sinks' to verify."