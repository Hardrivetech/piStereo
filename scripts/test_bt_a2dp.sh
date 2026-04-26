#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 <BT_MAC> [audio-file]
Example: $0 AA:BB:CC:DD:EE:FF /home/pi/test.mp3
If no file is provided the script will only pair/connect and set A2DP.
EOF
}

if [ "${1:-}" = "" ]; then
  echo "No device MAC provided. Listing known devices:"
  bluetoothctl devices || true
  echo
  usage
  exit 1
fi

MAC="$1"
FILE="${2:-}"

command -v bluetoothctl >/dev/null 2>&1 || { echo "bluetoothctl not found. Install bluez."; exit 2; }
command -v pactl >/dev/null 2>&1 || { echo "pactl not found. Install PipeWire/pulseaudio client tools."; exit 2; }

echo "Pairing/trusting/connecting to $MAC (you may need to accept on the phone)..."
bluetoothctl <<EOF
power on
agent on
default-agent
scan on
pair $MAC
trust $MAC
connect $MAC
quit
EOF

sleep 2

echo "Device info:"
bluetoothctl info "$MAC" || true

# find bluez card
card=$(pactl list cards short | awk '/bluez_card/{print $2; exit}') || true
if [ -z "${card:-}" ]; then
  echo "No bluez card detected; ensure device is connected and WirePlumber/BlueZ are running."
else
  echo "Using card: $card — setting A2DP profile"
  if pactl set-card-profile "$card" a2dp_sink 2>/dev/null; then
    echo "Profile set: a2dp_sink"
  elif pactl set-card-profile "$card" a2dp-sink 2>/dev/null; then
    echo "Profile set: a2dp-sink"
  else
    echo "Could not set A2DP profile. Available profiles for card:";
    pactl list cards | sed -n "/$card/,/Card profile/p" || true
  fi

  # find associated sink name
  sink=$(pactl list sinks short | awk '/bluez_sink/{print $2; exit}') || true
  if [ -n "${sink:-}" ]; then
    echo "Found sink: $sink — setting default sink"
    pactl set-default-sink "$sink" || true
  else
    echo "No Bluetooth sink found; streaming may still work if profile set."
  fi
fi

if [ -n "$FILE" ]; then
  if command -v mpv >/dev/null 2>&1; then
    echo "Playing $FILE through default sink (mpv)"
    mpv --no-video "$FILE"
  elif command -v paplay >/dev/null 2>&1; then
    echo "Playing $FILE with paplay"
    paplay "$FILE"
  else
    echo "No player available (mpv/paplay). Start playback from phone instead."
  fi
else
  echo "No file provided. Start playback from the phone to test streaming."
fi

exit 0
