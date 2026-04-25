Bench Smoke Tests — usage

Install files to the Pi (example):

```bash
sudo mkdir -p /opt/pi_headunit
sudo cp -r . /opt/pi_headunit
sudo cp systemd/pi_headunit_smoketest.service /etc/systemd/system/
sudo chmod +x /opt/pi_headunit/scripts/autotest.sh
sudo systemctl daemon-reload
```

Run the test manually:

```bash
# run the script under the scripts/ path
sudo /opt/pi_headunit/scripts/autotest.sh
# results are written to /var/log/pi_headunit_smoketest.last.json and appended to /var/log/pi_headunit_smoketest.json
```

Enable the oneshot service to run on demand (not automatic by default):

```bash
sudo systemctl enable --now pi_headunit_smoketest.service
# or run once on demand
sudo systemctl start pi_headunit_smoketest.service
```

Interpretation
- The script prints a JSON object summarizing checks for `pi_headunit` and `bluetooth` services, available PulseAudio/PipeWire sinks, `lsusb` output, and a quick GPIO probe.
- Exit code 0 means all basic checks passed. Non‑zero means at least one check failed — inspect `/var/log/pi_headunit_smoketest.json` for details.

When to use
- Run this before installing in the car to validate basic audio and input functionality.
- Use it during troubleshooting to collect a short snapshot of the system state.

