Audio & Bluetooth Setup — quick guide

1) Copy repo to the Pi (example):

```bash
sudo mkdir -p /opt/pi_headunit
sudo cp -r . /opt/pi_headunit
```

2) Run the installer to install system packages (requires root):

```bash
cd /opt/pi_headunit
sudo bash scripts/setup_audio.sh
```

3) Reboot the Pi:

```bash
sudo reboot
```

4) Pair a phone:
- Option A (interactive):
  - `bluetoothctl`
  - `power on`
  - `agent on`
  - `scan on`
  - When your phone appears: `pair <MAC>` then `trust <MAC>` then `connect <MAC>`
- Option B (helper script):
  - `sudo bash /opt/pi_headunit/scripts/pair_bluetooth.sh AA:BB:CC:DD:EE:FF`

5) Verify audio sink:

```bash
pactl list sinks short
# or
wpctl status
```

6) Playback test (PipeWire):

```bash
pw-play /usr/share/sounds/alsa/Front_Center.wav
# or from phone: stream via Bluetooth and adjust volume with
playerctl play-pause
playerctl next
```

Notes
- Some Pi OS images still use PulseAudio; the script installs `pipewire-pulse` which provides compatibility.
- If user services don't start automatically, enable user services for the Pi user: `loginctl enable-linger pi` and then `su - pi -c "systemctl --user enable --now pipewire pipewire-pulse wireplumber"`.
- Troubleshooting: check `journalctl -u bluetooth` and `journalctl --user -xe` for PipeWire errors.