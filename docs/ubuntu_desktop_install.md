Ubuntu 24.04 Desktop (Pi 5) — Desktop install guide for piStereo

Overview
- This guide shows the recommended, easy path: Ubuntu 24.04 LTS Desktop (64-bit) on Raspberry Pi 5. Desktop makes DSI touchscreen, calibration, GPU acceleration and GUI apps (OpenAuto) easier.

1) Image & flash
- Download the official Ubuntu 24.04 Desktop image for Raspberry Pi from https://ubuntu.com/download/raspberry-pi
- Flash with Raspberry Pi Imager (recommended) or BalenaEtcher.

2) First boot
- Create your user (or keep the default). For the docs and systemd units I use `pi` as an example user — either create `pi` or edit service file `systemd/pi_headunit_display.service` to match your username.
- Connect network and update the system:
```bash
sudo apt update
sudo apt upgrade -y
```

3) Install base packages & tools
- Install useful desktop tooling and touch calibrator (Xorg based):
```bash
sudo apt install -y xserver-xorg xinit x11-xserver-utils xinput xinput-calibrator libinput-tools python3 python3-pip git build-essential
```
- Install audio + Bluetooth (use the project's helper):
```bash
# run from the project repo root
sudo bash scripts/setup_audio.sh
```

4) Display & autostart services
- Enable the example display service (adjust `User=` inside the unit if your username is not `pi`):
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now pi_headunit_display.service
```
- If the display service does not run (no X session), enable automatic login so the GUI session exists for `DISPLAY=:0`:

GDM3 (default on Ubuntu Desktop)
1. Edit `/etc/gdm3/custom.conf` and set under `[daemon]`:
```
AutomaticLoginEnable=true
AutomaticLogin=pi
WaylandEnable=false
```
2. Reboot.

LightDM (alternative)
1. Create `/etc/lightdm/lightdm.conf.d/50-autologin.conf` with:
```
[Seat:*]
autologin-user=pi
autologin-session=ubuntu
```
2. Reboot.

Notes: disabling Wayland (`WaylandEnable=false`) forces Xorg which simplifies calibrators and some older OpenAuto builds.

5) Touchscreen calibration & input
- For Xorg, run `xinput_calibrator` and follow instructions. Save calibration to `/etc/X11/xorg.conf.d/99-calibration.conf` if needed.
- If your panel is Wayland-only you will need compositor-specific config; ask me if that's the case.

6) DSI panel (vendor overlays)
- DSI vendor overlays and firmware are device-specific. See `docs/dsi_panel.md` for details.
- Typical steps once you have the vendor archive:
  - Copy any `.dtbo` files to `/boot/firmware/overlays/`
  - Copy firmware blobs to `/lib/firmware/`
  - Add `dtoverlay=<name>` to `/boot/firmware/config.txt` (or append any recommended lines from the vendor README)
  - Reboot and verify with `dmesg | grep -i dsi` and `ls /sys/class/drm`

7) OpenAuto (options)
- OpenAuto Pro (commercial): easiest, supported; follow vendor install instructions, then set the systemd unit name in `/etc/pi_headunit/openauto.conf` (e.g., `openauto-pro.service`). I can help wire this into the repo after you have the installer/package.
- OpenAuto (open-source): works but requires building / dependencies. If you want this path I can add a build script.

8) Autostart OpenAuto only when phone connected
- You can use the event-driven udev rules (recommended) or the polling monitor in `src/openauto_monitor.py`.
- To install the udev rules (event-driven):
```bash
sudo bash scripts/install_openauto_udev.sh
```
- To use the polling monitor instead:
```bash
sudo bash scripts/install_openauto_monitor.sh
```

9) Useful commands & tests
```bash
# check display service
systemctl status pi_headunit_display.service
# check OpenAuto service (replace name if you use openauto-pro.service)
systemctl status openauto.service
# watch logs
sudo journalctl -f
```

10) Next steps I can help with
- Prepare a ready-to-run image or unattended install steps
- Add a small setup script to create a `pi` user, configure autologin, and enable the display + OpenAuto services
- Help install OpenAuto Pro once you have the package

Files I added/updated
- [docs/dsi_panel.md](docs/dsi_panel.md) — DSI guidance
- [systemd/pi_headunit_display.service](systemd/pi_headunit_display.service) — example display service
- [scripts/setup_audio.sh](scripts/setup_audio.sh) — audio stack helper
- [scripts/install_openauto_udev.sh](scripts/install_openauto_udev.sh) — udev installer
- [scripts/install_openauto_monitor.sh](scripts/install_openauto_monitor.sh) — polling monitor installer

If you want, I can now:
- create a single `setup-desktop.sh` script that: creates `pi` user (if missing), sets autologin, installs packages, runs `scripts/setup_audio.sh`, enables the display service, and installs udev rules — or
- produce a short checklist you can follow manually (I already added one above).
