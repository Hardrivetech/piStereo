piStereo — Wiring harness & connectors

Purpose
- Define connector pinouts for the double‑DIN headunit rear panel and a robust wiring harness for power, audio, and speaker connections.

Connectors (recommended layout)
- Power / control (4-pin screw terminal or Molex):
  - Pin 1: BAT (Constant +12 V)
  - Pin 2: ACC (Ignition switched +12 V)
  - Pin 3: GND (Chassis ground)
  - Pin 4: AMP_REMOTE (12 V remote-turn-on output)

- RCA preouts (panel mount, labeled):
  - `RCA_FRONT_L`, `RCA_FRONT_R` — front preamp outputs
  - `RCA_REAR_L`, `RCA_REAR_R` — rear preamp outputs
  - `RCA_SUB_L`, `RCA_SUB_R` — subwoofer preouts (use mono if your amp expects a single sub input)

- Speaker outputs (screw terminal block):
  - Block A: `FL+`, `FL-`, `FR+`, `FR-`
  - Block B: `RL+`, `RL-`, `RR+`, `RR-`
  - Note: these are outputs from the external amplifier. If you want to provide direct Pi speaker outputs (not recommended), label separately.

- USB / Aux / Diagnostics:
  - `USB-A` or `USB-C` port on the rear for a USB audio interface or flash drives
  - Optional `UART` pins for diagnostics (if you put a small debug header)

Physical wiring recommendations
- RCA: use shielded coax; connect shield to chassis ground at one end (headunit) only.
- Speaker wires: use 16–18 AWG for short runs; 14–16 AWG for longer runs or high-power speakers. Use twisted pairs where practical.
- Power wiring: use appropriately sized wire and ring terminals; place a fuse on the BAT feed close to the source.

Pin mapping to Pi (defaults in `config/config.ini`)
- These use BCM numbering (change in `config/config.ini` if you rewire):
  - `vol_encoder_a = 17` (BCM 17)
  - `vol_encoder_b = 27` (BCM 27)
  - `vol_switch = 22` (push the encoder)
  - `btn_prev = 5`  
  - `btn_next = 6`
  - `btn_play = 13`
  - `btn_power = 19`
  - `acc_sense = 26`

Connector assembly notes
- Use keyed connectors or shrouded housings to avoid miswiring during installation.
- Label both ends of each harness with a durable tag (front-left, front-right, ACC, BAT, etc.).
- Keep audio RCA runs away from high-current power wiring; cross at 90° where they must intersect.

Testing checklist
- Continuity checks: verify each pin on the panel connector reaches the intended harness end.
- Power test: with fuse in place, apply 12 V and verify the buck converter provides 5 V and the ACC sense produces the expected GPIO voltage.
- Audio routing: confirm USB audio interface outputs appear on the RCA jacks and are correctly labeled.

Notes about vehicle integration (1988 Chrysler Conquest)
- Classic vehicles may not have a standard ISO harness; you will likely build a custom pigtail to the factory speaker wires and a fuse-tap for ACC/BAT.
- Use a multimeter and wiring diagrams specific to the vehicle when locating ACC and constant battery circuits. If unsure, ask for photos of the car harness and I can suggest exact tapping points.

If you'd like, I can produce:
- A printable drill/template for a double-DIN chassis cutout and panel layout, or
- A shopping list of connectors and a connectorized harness BOM.
