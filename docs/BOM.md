Bill of Materials (recommended

Core SBC
- Raspberry Pi 5 (1x)
- High‑endurance microSD (32–128 GB)

Audio
- Option A (recommended): USB multichannel audio interface (4‑out) — e.g., Behringer UMC404HD or similar (for front/rear/sub preouts)
- Option B: I2S multichannel HAT (AudioInjector/Allo) if you prefer HAT-style
- RCA panel jacks (3 × stereo pairs: front, rear, sub)
- Shielded RCA cables
- Ground loop isolator (if hum)

Amplification & Speakers
- 4‑channel car amplifier (or 2x stereo amps) with RCA inputs and speaker outputs
- Speaker terminal block or panel‑mount screw terminals for the rear of the unit

Power & Control
- Automotive DC→5V buck converter (6–10A rated, automotive grade)
- In‑line fuse holder + appropriate fuse (10–15A for Pi + audio hardware)
- Power management / ignition sense module OR relay + latching power controller (recommended: off‑the‑shelf car power controller supporting auto shutdown)
- TVS transient suppressor on VIN (optional for extra surge protection)

Controls & Connectors
- Rotary encoder with push (detent) for volume (ALPS/EC11 style)
- Momentary pushbuttons for forward/back/play/power
- Panel screws, mounting brackets, double‑DIN chassis or universal bezel

Misc
- Shielded twisted pair or shielded stereo cable for RCA runs
- Ring terminal for chassis ground
- Heat shrink, wiring loom, zip ties

Notes
- The USB multichannel interface simplifies generating separate RCA preouts; small I2S HATs often provide only stereo.
- Use a separate subwoofer RCA output driven from the sub channel (post‑DSP or post‑lowpass) on the DAC or via the amplifier's sub input.
- Choose an automotive rated buck converter and fuse the battery feed close to the battery or source.

If you want, I can convert this BOM into a shopping list with example SKUs and links.