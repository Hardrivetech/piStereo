OpenAuto: start only when a phone is connected

Overview
- This project includes a small monitor that will start/stop a systemd service (default `openauto.service`) when a phone is detected via USB/ADB/MTP.

What I added
- `src/openauto_monitor.py` — polling monitor (checks `adb devices`, MTP probe, and `lsusb` vendor IDs).
- `config/openauto.conf` — default settings (service name, poll interval, vendor IDs).
- `systemd/openauto-monitor.service` — systemd unit to run the monitor.
- `scripts/install_openauto_monitor.sh` — installer to copy files to `/opt/pi_headunit`, place config in `/etc/pi_headunit`, and enable the systemd service.

Install (from the repo root)
```bash
sudo bash scripts/install_openauto_monitor.sh
```

Test & debug
```bash
# follow the monitor output
sudo journalctl -u openauto-monitor -f
# see OpenAuto service status
systemctl status openauto.service
```

Customization
- To change the systemd service that gets started, edit `/etc/pi_headunit/openauto.conf` and set `service_name` to your OpenAuto service (for OpenAuto Pro that might be `openauto-pro.service`).
- To add/adjust USB vendor IDs (to detect specific phones), edit the `vendor_ids` comma-separated list in the same config file.

Udev alternative (lower latency)
- If you prefer event-driven behavior instead of polling, you can install udev rules that call `systemctl` on add/remove of USB devices matching `ID_VENDOR_ID`.
- Example (place in `/etc/udev/rules.d/99-openauto-phone.rules`)

```
# start when a device with vendor 18d1 (Google) is added
ACTION=="add", SUBSYSTEM=="usb", ENV{ID_VENDOR_ID}=="18d1", RUN+="/bin/systemctl start openauto.service"
# stop when removed
ACTION=="remove", SUBSYSTEM=="usb", ENV{ID_VENDOR_ID}=="18d1", RUN+="/bin/systemctl stop openauto.service"
```

Notes & caveats
- Polling is simpler and portable; udev rules are lower-latency but can be trickier (and udev runs in a limited environment).
- Detection is heuristic: `adb` detection requires developer options/USB debugging on the phone; MTP/lsusb vendor IDs are broader.
- Make sure the `service_name` refers to an installed systemd unit for OpenAuto.

Questions
- Do you want me to (choose one):
  - add a udev-rule installer and sample rules for common phone vendors, or
  - wire the monitor to detect Android Auto-specific USB interfaces (needs vendor/product IDs from your phone)?

Udev installer (recommended)
- I added an event-driven installer that places a udev rule to start/stop OpenAuto when a phone is plugged/unplugged. This avoids polling and is lower-latency on connect/remove.
- Files added in the repo:
  - `udev/99-openauto-phone.rules` — sample rules for common vendor IDs.
  - `scripts/install_openauto_udev.sh` — installer to copy the rule into `/etc/udev/rules.d`, reload udev, and disable the polling monitor if present.

Install the udev rule (from the repo root):
```bash
sudo bash scripts/install_openauto_udev.sh
```

Remove / uninstall (recommended)
```bash
sudo bash scripts/uninstall_openauto_udev.sh
```
During install the script records the previous state of the polling monitor (if present) to
`/etc/pi_headunit/openauto_udev.state`. The uninstall script will consult this file and only
re-enable the polling monitor if it was enabled before the udev rule was installed.

The uninstall script moves the rule to `/etc/udev/rules.d/99-openauto-phone.rules.bak`, reloads udev, and will re-enable the polling monitor (`openauto-monitor.service`) only if it was enabled prior to the udev install.

Notes
- The udev rules use `ENV{ID_VENDOR_ID}` to match common phone vendors. If your phone doesn't trigger the rule, plug it in and run `lsusb` to discover the vendor/product IDs to add.
- udev runs commands in a limited environment; the rules use the full path `/bin/systemctl` to reliably control services.
