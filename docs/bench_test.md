piStereo — Bench build & test checklist

Purpose
- Safely validate power, controls, audio, Bluetooth, and shutdown behavior on the bench before installing in the car.

Required tools
- Regulated 12 V bench supply or fused 12 V battery source
- Multimeter
- Audio test speaker or dummy load (4–8 Ω) and speaker wire
- Shielded RCA cable
- USB keyboard/monitor or SSH access to the Pi
- Fuse (10 A recommended for Pi feed during bench tests)

Safety first
- Always fuse the 12 V feed near the supply.
- Use proper AWG wiring for the load you're testing.
- Keep speaker volume low when first testing to avoid damage.

Pre-checks
1. Verify buck converter and wiring:
   - Connect bench 12 V → inline fuse → buck VIN.
   - With no load, measure buck VOUT; should be ~5.00 V.
   - Add a 2–3 A load and verify VOUT remains stable.

Commands (on bench Pi):
```bash
# check service
systemctl status pi_headunit
# check logs
journalctl -u pi_headunit -f
# check audio sinks
pactl list sinks short
# check bluetooth service
systemctl status bluetooth
lsusb
```

Step 1 — Power & ACC sense
- Wire ACC to your ACC test source (switched 12 V). Verify the ACC sense circuit output (voltage divider or optocoupler) gives ~3.2–3.3 V to the Pi GPIO when ACC=12 V and ~0 V when ACC=0 V.
- Run the GPIO test script (below) to observe ACC state.

Step 2 — Boot the Pi
- Apply 5 V to the Pi from the buck. Boot the OS and SSH in.
- Confirm `pi_headunit` service is running and `src/gpio_daemon.py` shows no errors in `journalctl`.

Step 3 — Controls validation
- Run the GPIO test script to observe raw pin states:
```bash
sudo python3 /opt/pi_headunit/src/gpio_test.py
```
- Rotate the encoder and press buttons; ensure the script shows state changes.
- Verify `playerctl` commands control media when a player is running (or a Bluetooth device is connected):
```bash
playerctl play-pause
playerctl next
playerctl previous
```

Step 4 — Audio interface & RCA outputs
- Plug in the USB audio interface and confirm recognition:
```bash
lsusb
pactl list sinks short
```
- If the interface doesn't appear, check `dmesg` for driver errors.
- Play a test tone (low volume):
```bash
# if pw-play installed (PipeWire)
pw-play /usr/share/sounds/alsa/Front_Center.wav
# or with speaker-test (ALSA)
speaker-test -t sine -f 440 -c 2
```
- Confirm audio is present at the RCA preouts with a scope or by listening via the amp.

Step 5 — Bluetooth streaming
- Use `bluetoothctl` to pair and trust a phone, then connect and start streaming audio from the phone.
```bash
bluetoothctl
power on
agent on
scan on
# wait, then pair <addr>, trust <addr>, connect <addr>
```
- Confirm the Sink appears in `pactl` and audio plays.

Step 6 — Amplifier remote & speaker outputs
- Connect amplifier `REMOTE` to the `AMP_REMOTE` output (or ACC if you prefer). With low volume, play audio and confirm the amp powers on and drives the speaker test load.
- Use a dummy load or a small speaker. Start at low volume.

Step 7 — Shutdown & auto-power behavior
- Test long-press power button to trigger a safe shutdown (hold time set in `/etc/pi_headunit/config.ini`).
- Test ACC off: remove ACC input and confirm Pi runs clean shutdown and final power is removed by your power controller (or PWR_HOLD release).

Step 8 — Troubleshooting
- No audio: verify default sink with `pactl list short sinks` and route audio to the correct sink with `pactl set-default-sink <NAME>`.
- Buttons not detected: check `journalctl -u pi_headunit` and run `gpio_test.py` to observe raw values.
- Bluetooth not pairing: ensure `bluetooth` service active and `bluetoothctl` shows the adapter powered and discoverable.
- Hum: try a ground loop isolator on RCA and ensure single-point chassis ground.

Useful debug commands
```bash
# show USB devices
lsusb
# kernel messages
dmesg | tail -n 50
# PulseAudio / PipeWire sinks
pactl list sinks
# follow system logs
journalctl -f
```

When bench tests pass
- Securely mount components in the double‑DIN chassis and proceed to vehicle installation.
- Run a final audio-check at low volume in the car before full installation.

Files
- GPIO realtime checker: `/opt/pi_headunit/src/gpio_test.py` (run with sudo)

If you want, I can generate a single-page printable checklist PDF for the bench steps.
