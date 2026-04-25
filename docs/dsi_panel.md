DSI panel setup — Raspberry Pi 5 (Ubuntu 24.04)

Overview
- DSI (MIPI DSI) panels connect via the Pi's DSI connector and typically require a vendor-supplied device-tree overlay (.dtbo) and/or kernel driver.
- Many DSI panels (especially vendor/proprietary ones) provide drivers/overlays targeted at the Raspberry Pi OS kernel; on Ubuntu you may need to install or build drivers for the Ubuntu kernel.

High-level steps
1) Confirm vendor model & download driver package
- Get the vendor package (tar/zip) that contains any of: `.dtbo` files, firmware blobs (`.bin`), kernel modules, and an install script or README.

2) Prepare the Pi (Ubuntu)
- Use Ubuntu 24.04 LTS 64-bit for best Pi 5 support.
- Install helpful tools:

```bash
sudo apt update
sudo apt install -y build-essential device-tree-compiler libinput-tools xinput-tools evtest
# (Optional) install linux headers if you need to build kernel modules:
sudo apt install -y linux-headers-$(uname -r)
```

3) Install vendor overlays / firmware
- Unpack the vendor archive on the Pi and copy overlays/firmware to the firmware locations used by Ubuntu on Pi:

```bash
# example, adjust paths from vendor archive
sudo cp vendor/overlays/*.dtbo /boot/firmware/overlays/
sudo cp vendor/firmware/* /lib/firmware/
```

4) Update `config.txt`
- Edit `/boot/firmware/config.txt` and add the vendor overlay line (replace with the overlay name from the vendor):

```ini
# add vendor overlay (example name)
dtoverlay=vendor_dsi_overlay

# if required by the panel, enable I2C/SPI
# dtparam=i2c_vc=on
# dtparam=i2c_arm=on
# dtparam=spi=on
```

- If the driver requires the vc4 KMS driver, ensure it's enabled (`dtoverlay=vc4-kms-v3d`) but read vendor docs — conflicting overlays can break the display.

5) If kernel modules are provided
- Build/install them per vendor instructions. Typical steps:

```bash
cd vendor/driver
sudo make
sudo make install
sudo depmod -a
sudo modprobe vendor_module_name
```

6) Reboot and verify

```bash
sudo reboot
# after boot
dmesg | grep -i -E "dsi|drm|fb|mipi"
ls /sys/class/drm
# if X/Wayland is running
xrandr --listmonitors
```

7) Test touchscreen input
- Find the input device and test events:

```bash
xinput list
# find the event node (or use evtest)
evtest /dev/input/eventN
# libinput info
libinput list-devices
```

8) Rotation & calibration
- If the touch coordinates do not match orientation, use `xinput set-prop <ID> "Coordinate Transformation Matrix" ...` (X11) or libinput + compositor settings for Wayland. `xinput_calibrator` can help (X11).

Caveats & troubleshooting
- Vendor drivers often target Raspberry Pi OS; if no prebuilt driver is provided for Ubuntu you will need to build against your kernel. If building isn't possible, the vendor may only support Raspberry Pi OS — consider using that image if needed.
- If the overlay fails to attach or you see no DRM connector under `/sys/class/drm`, remove the overlay and check `dmesg` for errors.
- If touch works but the display is blank, check framebuffer/drm logs in `dmesg` and ensure firmware blobs were copied to `/lib/firmware`.

Integrating with the headunit UI
- Once the DSI screen and touch are working, the `src/display_now_playing.py` script will run fullscreen on the primary display. You can autostart it with the sample systemd unit `systemd/pi_headunit_display.service` (edit `User=` to match your account).

If you share the exact Osoyoo DSI model (or the vendor archive contents), I can draft the exact `dtoverlay=` line, the files to copy, and a tested `config.txt` snippet for your case.