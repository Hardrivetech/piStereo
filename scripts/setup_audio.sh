#!/bin/bash
set -e
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root: sudo ./setup_audio.sh"
  exit 1
fi

echo "Updating APT and installing audio + Bluetooth packages..."
apt update
apt install -y pipewire pipewire-pulse wireplumber pipewire-audio-client-libraries \
  bluez bluez-tools pulseaudio-utils pavucontrol playerctl alsa-utils

# Enable bluetooth service
systemctl enable --now bluetooth

# If user 'pi' exists, enable user pipewire services for it
if id pi >/dev/null 2>&1; then
  echo "Enabling user PipeWire services for 'pi' (enable-linger + user services)."
  loginctl enable-linger pi || true
  su - pi -c "systemctl --user enable --now pipewire pipewire-pulse wireplumber || true"
fi

echo "Installation complete. Recommend rebooting the Pi now."
echo "After reboot, pair a phone with bluetoothctl or use the included pair_bluetooth.sh helper."
