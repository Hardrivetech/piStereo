piStereo — Power Management

Purpose
- Provide a robust automotive 12V → 5V supply for the Raspberry Pi 5 and peripherals.
- Detect ignition (ACC) to trigger a safe shutdown.
- Provide a controlled remote-turn-on for the car amplifier.
- Protect against transients and faults (fuse, TVS, filtering).

Summary / recommendations
- Use an automotive-rated DC→DC buck converter (5V output) sized 6–10 A depending on display/audio peripherals. This removes stress from the Pi's on-board regulator and gives headroom.
- Use an off‑the‑shelf car power controller module ("auto power off" / "car PC power controller") if you want a simple, safe solution — it handles ignition sense, timed shutdown, and latching power.
- If DIY, implement an ignition sense (voltage divider + RC filter or optocoupler), a soft-latch or latching-relay power hold, and an amplifier-remote switch controlled from ACC or Pi.

Power budget guidance
- Estimate the Pi 5 + USB audio interface + touch display draw and add ~30% overhead. If you expect <3–4 A choose 6 A buck; for heavier setups choose 8–10 A.
- Amplifier should be powered separately from the Pi (from battery via its own fused feed); do not power the amplifier from the Pi's buck.

Recommended components (examples)
- DC→DC buck: 12V → 5V, 6–10 A, automotive-rated (example category: "12V to 5V 10A automotive buck converter"). Avoid generic LM2596 modules unless you add filtering and fusing.
- Inline fuse & holder: fuse near the battery/source (10 A primary for the Pi + accessories branch). Use slow-blow if you have large inrush devices.
- TVS surge protection: SMBJ series (choose appropriate standoff voltage) or similar across VIN to clamp spikes.
- Power controller (recommended): "Car PC auto power off" module or commercial car power controller that supports ACC sense + timed shutdown and remote open collector output. This is safest for unattended vehicles.
- Optional parts for DIY: P-channel MOSFET (high-side), NPN transistor/MOSFET for gate drive, latching relay (12V), optocoupler (for isolation on ACC), resistors, caps, small PCB.

Ignition (ACC) sense — simple, safe method
Method A — resistor divider + RC filter (easy to build):
- Tap ACC (switched 12V) through an inline fuse/tap.
- Use a resistor divider to scale 12V to ~3.2–3.3 V for a Pi GPIO.
  - Example values: R_top = 27 kΩ, R_bottom = 10 kΩ
    - Vout = Vin * Rbottom / (Rtop + Rbottom)
    - For 12 V: Vout ≈ 12 * 10 / 37 ≈ 3.24 V (safe logic HIGH for 3.3 V inputs).
- Add a small capacitor from the divider output to ground (e.g., 10–100 nF) to filter short spikes.
- Add a series resistor (~4.7–10 kΩ) between divider node and the GPIO to limit current and help with transients.
- Optionally clamp with a 3.6 V zener to protect the GPIO if divider tolerances worry you.

Method B — optocoupler isolation (recommended if you want galvanic isolation):
- Run ACC through a current-limiting resistor into the LED side of an optocoupler; on the output transistor side pull up to 3.3 V and feed the GPIO.
- This isolates automotive noise and gives a robust logic-level signal.

Soft shutdown & power hold (two approaches)
Option 1 — Off-the-shelf power controller (recommended):
- Buy a car power controller module that senses ACC, keeps power alive for a configurable timeout while the Pi cleanly shuts down, and then cuts the 5 V rail after shutdown. This avoids fragile DIY timing and race conditions.

Option 2 — DIY soft-latch using a high-side switch or latching relay:
- Use a high-side P-channel MOSFET or a dedicated load-switch IC to connect battery (fused) to the buck input.
- Use a momentary power button to momentarily turn the MOSFET on. After boot, the Pi asserts a `PWR_HOLD` GPIO to keep the MOSFET gate driven so power stays on.
- On ignition off or a long press on power, the Pi runs `systemctl poweroff` and then clears `PWR_HOLD`. An external watchdog (or the power controller) must then remove mains power after the Pi halts.
- Note: properly implementing the final power cutoff is tricky — systemd will stop user space processes and may not guarantee that a user process can toggle the hold pin late in shutdown. Prefer a hardware timer or dedicated module that waits a configurable interval after detecting that the Pi has halted (or that monitors a dedicated GPIO that is still driven by a small MCU until the Pi signals it to release).

Amplifier remote-turn-on
- The amplifier's `REMOTE` terminal should be connected either to ACC (so amp turns on with ignition), or to a Pi-controlled transistor/MOSFET that pulls the remote to +12V after the Pi boots.
- Use an N-channel MOSFET or NPN transistor to switch the remote line, with a resistor on the base/gate and a flyback diode if necessary.

Software interactions (existing files)
- The `src/gpio_daemon.py` included in the repo already monitors an ACC pin and calls `systemctl poweroff` when ACC goes low. It also reacts to a long-press of the power button.
- Add a `PWR_HOLD` GPIO (wired into your soft-latch hardware or power controller) — set it high on startup, clear it only after the Pi shutdown completes (or let the external power controller handle the final cutoff).

Bench testing checklist
1. Do not connect to the car — bench test with a 12 V supply and fuse.
2. Verify buck converter output is stable at 5.00 V under load before connecting Pi.
3. Verify ACC divider output is ~3.2–3.3 V when ACC=12 V and near 0 V when ACC=0 V.
4. Test amplifier remote switching with a test lamp or the amp's remote input.
5. Test safe shutdown: flip ACC off, confirm Pi performs clean shutdown and that final power removal occurs after shutdown timeout.

Safety notes
- Fuse everything close to the battery or source.
- Use automotive-grade wiring, connectors and soldering; crimped ring terminals are preferred.
- Add transient suppression (TVS) if the vehicle is old or noisy.
- Keep grounds tidy and use a single chassis ground point to minimize ground loops in audio.

If you want, I can:
- Draw a detailed PCB-level schematic for the soft-latch circuit, or
- Recommend specific off-the-shelf car power controller modules with SKUs and shopping links.
