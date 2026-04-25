Touchscreen support (Ubuntu + Pi 5)

Short answer
- Yes — you can use Ubuntu on Raspberry Pi 5. Ubuntu 24.04 LTS (64-bit) or Ubuntu Server + desktop environment are good choices for a touchscreen headunit.

Identify the display interface
- Common types:
  - HDMI display + USB touch controller (plug-and-play on Ubuntu)
  - DSI / HAT (requires a device-tree overlay / vendor driver)
  - eDP/parallel panels (may need vendor kernel modules)
- I attempted to fetch the Osoyoo product page you linked but the page redirected; please confirm whether the Osoyoo screen uses HDMI+USB (recommended) or a HAT/DSI connector.

If your display is HDMI + USB (typical, easiest)
1. Connect HDMI to Pi HDMI output and USB to a Pi USB port.
2. Ubuntu will detect the monitor and the touch device (HID). Check:
   - `lsusb`
   - `xinput list` (X11) or `libinput list-devices` (Wayland)
   - `evtest /dev/input/eventX` to see raw events
3. Calibrate (X11):
   - `sudo apt install xinput-calibrator`
   - Run `xinput_calibrator` and follow instructions.
4. Rotation mapping:
   - Rotate display: `xrandr --output HDMI-1 --rotate left` (replace output name)
   - Map touch to rotated screen: use `xinput set-prop <TOUCH_ID> "Coordinate Transformation Matrix" ...` (search for examples; `xinput_calibrator` prints the matrix)
5. Wayland: libinput performs calibration automatically in many cases; use desktop Settings for orientation.

If your display is a DSI/HAT panel (requires vendor support)
- Check product docs for a device-tree overlay or driver package.
- On Ubuntu for Raspberry Pi, the config file is ` /boot/firmware/config.txt` — add overlays as vendor docs request (e.g., `dtoverlay=your_overlay`).
- Reboot after editing `config.txt`.
- If vendor supplies a kernel module or installer, follow their steps (often a small install script or dtbo file).

Ubuntu notes
- Use Ubuntu Desktop if you want a full GUI (recommended for touchscreen apps).
- On headless images, install a lightweight desktop (LXDE, XFCE) for lower resource use.
- Keep `pipewire`, `wireplumber`, and `bluez` installed for audio/Bluetooth.

Kiosk / Now‑Playing UI
- Recommended approach: a small fullscreen app that subscribes to MPRIS (playerctl / PipeWire) to show metadata and album art.
- Options:
  - Web-based UI (local webserver + Chromium in kiosk mode).
  - Qt/GTK app (PyQt5/PySide6 is simple for a touchscreen UI).
  - Use the included `src/display_now_playing.py` (Tkinter) as a quick starting point.

Testing commands
- `lsusb`
- `xinput list`
- `libinput list-devices`
- `evtest /dev/input/eventX`
- `xrandr --listmonitors`

If you confirm the Osoyoo display's interface (HDMI+USB vs DSI/HAT), I will add device-specific setup steps and, if available, driver lines (dt-overlay) to the repo.
