Raspberry Pi OS Desktop (64-bit) — Install & setup for piStereo

Overview
- Recommended: Raspberry Pi OS (64-bit) Desktop for Raspberry Pi 5. Desktop simplifies touchscreen/DSI setup, autologin, and running GUI apps like OpenAuto.

1) Image & flash
- Download Raspberry Pi OS (64-bit) Desktop using the Raspberry Pi Imager: https://www.raspberrypi.com/software/
- Flash the SD card with Raspberry Pi Imager or BalenaEtcher.

2) First boot & update
```bash
sudo apt update
sudo apt full-upgrade -y
sudo reboot
```

3) User & autologin
- Example services use `pi` as the username. Either create a `pi` user, or edit `systemd/pi_headunit_display.service` to match your user.
- Recommended: enable Desktop autologin so GUI session `:0` exists for kiosk/display services.

Use raspi-config (interactive):
```bash
sudo raspi-config
# Navigate to: System Options -> Boot / Auto Login -> Desktop Autologin
```

4) Install audio, Bluetooth and GUI helpers
- Install required packages (PipeWire + WirePlumber recommended; PulseAudio alternatives may exist):
```bash
sudo apt install -y python3 python3-pip git xserver-xorg x11-xserver-utils xinput xinput-calibrator \
  alsa-utils pavucontrol playerctl bluez bluez-tools pipewire wireplumber libspa-0.2-bluetooth
```
- You can also run the repo helper to set up audio (may work on Raspberry Pi OS):
```bash
sudo bash scripts/setup_audio.sh
```

5) Display service & autostart
- Enable the example display service (adjust `User=` inside the unit if your username is not `pi`):
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now pi_headunit_display.service
```
- If autologin is set, the service should be able to connect to `DISPLAY=:0`.

6) DSI panel & vendor overlays (Raspberry Pi OS specifics)
- On Raspberry Pi OS, overlays go in `/boot/overlays/` and the main boot config is `/boot/config.txt`.
- Typical steps after you obtain the vendor archive:
  1. Copy vendor `.dtbo` files to `/boot/overlays/`.
  2. Copy firmware blobs to `/lib/firmware/`.
  3. Add the vendor `dtoverlay=` line (or other vendor lines) to `/boot/config.txt`. Example append:
```bash
echo 'dtoverlay=your_panel_overlay' | sudo tee -a /boot/config.txt
```
  4. Reboot and verify with:
```bash
dmesg | grep -i dsi
ls /sys/class/drm
```
- See `docs/dsi_panel.md` for general guidance. I can update that doc with Raspberry Pi OS-specific snippets if you provide the vendor archive or model.

7) Touch calibration
- For Xorg run `xinput_calibrator` and follow prompts; save the generated config to `/etc/X11/xorg.conf.d/99-calibration.conf` if needed.

8) OpenAuto (Android Auto)
- OpenAuto Pro (commercial) is the easiest route; follow vendor installer and set its systemd unit name in `/etc/pi_headunit/openauto.conf`.
- OpenAuto (open-source) can be built from source; let me know if you want a build script.

9) Autostart OpenAuto only when a phone is connected
- Use the repo's event-driven udev rules (recommended):
```bash
sudo bash scripts/install_openauto_udev.sh
```
- Or use the polling monitor (already included) if you prefer:
```bash
sudo bash scripts/install_openauto_monitor.sh
```

10) Verify & debug
```bash
# display service
systemctl status pi_headunit_display.service
# openauto service (replace with your unit name)
systemctl status openauto.service
# view logs
sudo journalctl -f
```

11) Next steps I can do for you
- Create a single `scripts/setup_raspios.sh` that: creates/ensures `pi` user, enables autologin, installs packages, runs `scripts/setup_audio.sh`, enables the display service, and installs the chosen OpenAuto autostart (udev or monitor).
- Update `docs/dsi_panel.md` with Raspberry Pi OS-specific examples if you provide the vendor files or model.

Files referenced
- `systemd/pi_headunit_display.service`
- `scripts/setup_audio.sh`
- `scripts/install_openauto_udev.sh` and `scripts/install_openauto_monitor.sh`
- `docs/dsi_panel.md`

If you want the automated `scripts/setup_raspios.sh`, should it create the `pi` user automatically, or do you prefer to create the user yourself and have the script only configure services?

Automated setup script
- The repo includes `scripts/setup_raspios.sh` which performs the common setup steps automatically:
  - creates the `pi` user (if missing) and adds it to common hardware groups
  - enables LightDM autologin for `pi`
  - installs required packages and runs `scripts/setup_audio.sh`
  - deploys the project to `/opt/pi_headunit`, enables `pi_headunit_display.service`, and installs OpenAuto udev rules

Run it from the repo root:
```bash
sudo bash scripts/setup_raspios.sh
```

After the script completes, set a password for the `pi` account:
```bash
sudo passwd pi
```

Script options
- `--dry-run`: preview actions the script will take without making changes. Useful to verify before running.
- `--skip-udev`: skip installing the OpenAuto udev rules (useful if you prefer the polling monitor or want to manage udev rules manually).

Examples
```bash
# preview actions
sudo bash scripts/setup_raspios.sh --dry-run

# run but skip udev rules
sudo bash scripts/setup_raspios.sh --skip-udev
```