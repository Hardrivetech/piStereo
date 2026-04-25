piStereo — Raspberry Pi 5 Double‑DIN Headunit

Overview
- Purpose: Double‑DIN car headunit for 1988 Chrysler Conquest using Raspberry Pi 5.
- Features: dedicated volume knob, power button, forward/back/play buttons, RCA preouts (front/rear/sub), speaker outputs via amplifier, Bluetooth A2DP streaming.

What I added
- BOM and notes: docs/BOM.md
- Example GPIO control daemon: src/gpio_daemon.py
- Default config: config/config.ini (copy to /etc/pi_headunit/config.ini)
- systemd unit for the daemon: systemd/pi_headunit.service
- Simple installer script: scripts/install.sh
- Python requirements: requirements.txt

Quick install (on the Pi)
1) Update OS and install packages:

```bash
sudo apt update
sudo apt install -y python3-pip playerctl pulseaudio-utils bluez bluez-tools wireplumber pipewire pipewire-pulse
sudo pip3 install -r /opt/pi_headunit/requirements.txt
```

2) Deploy files (example):

```bash
sudo mkdir -p /opt/pi_headunit
sudo cp -r . /opt/pi_headunit
sudo mkdir -p /etc/pi_headunit
sudo cp config/config.ini /etc/pi_headunit/config.ini
sudo cp systemd/pi_headunit.service /etc/systemd/system/pi_headunit.service
sudo systemctl daemon-reload
sudo systemctl enable --now pi_headunit.service
```

3) Pair Bluetooth: use `bluetoothctl` to pair a phone; PipeWire + BlueZ should expose A2DP sink.

GPIO mapping and tuning: Edit `/etc/pi_headunit/config.ini` to match your wiring.

Next steps I can take
- Produce a detailed wiring diagram and power-management schematic
- Produce a mounting/enclosure template for double‑DIN
- Help pick a multichannel DAC or USB audio interface and amplifier

Tell me which next deliverable you want.