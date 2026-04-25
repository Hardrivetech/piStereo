Enclosure & Mounting — piStereo Double‑DIN Headunit

Overview
- Standard double‑DIN opening: 180 mm × 100 mm.
- This design provides a printable 1:1 faceplate template, mounting guidance, and recommended clearances for the Raspberry Pi 5 + USB audio interface.

Dimensions & clearances
- Faceplate outer footprint (recommended): 186 mm × 106 mm (gives 3 mm flange around the 180×100 opening).
- Opening cutout: 180 mm × 100 mm (centered).
- Recommended internal pocket depth: minimum 60 mm behind the dash for Pi + small DAC; 90–120 mm if adding a small amplifier or robust heat sinking.
- Clearance around PCBs: allow 10–15 mm on each side for connectors and cables.

Mounting options
1) Use a universal double‑DIN metal pocket (commercial) — easiest and safest.
2) Fabricate a custom cage from 1.5–2.0 mm sheet metal with M4 threaded mounting points and a removable rear panel for connectors.
3) 3D‑print a bezel / chassis for low‑vibration non‑structural mounting (add metal inserts for screws).

Front panel cutouts (suggested)
- Volume encoder: 6 mm shaft hole (drill 6.5 mm for tolerance) at 20 mm from left edge, vertically centered.
- Power button: 8 mm hole at 12 mm from top-left corner.
- Prev / Next / Play buttons: 12 mm panel holes arranged horizontally near lower center (spacing ≈ 25–30 mm).
- Screen: If you add a display, ensure it fits inside the 180×100 opening or design a recess to accept the display bezel.

Ventilation
- Add vent slots on the top and/or rear of the chassis (multiple 4–6 mm slots) to avoid heat buildup.
- If enclosing a USB audio interface or small amp, provide dedicated vents or a small fan.

Rear panel
- Include a rectangular cutout for a connector plate with: RCA preouts (3 pairs), screw speaker terminals, power screw terminal (BAT/ACC/GND/REMOTE), USB port access, and optionally a fuse holder.
- Label connectors clearly on the plate.

Mounting PCBs
- Use 6 mm nylon standoffs (M3) to secure the Pi to an internal bracket.
- Provide a small metal bracket for the USB audio interface; secure it to the chassis to avoid cable stress.

Serviceability
- Make the rear connector plate removable (4 screws) for quick access to RCA and speaker terminals.
- Keep Pi SD card accessible (side slot) or provide a removable panel for updates.

Materials & finish
- Front bezel: ABS plastic 2–3 mm (paintable) or powder‑coated steel for a premium look.
- Chassis: 1.5–2.0 mm steel recommended for rigidity and grounding.

Safety & grounding
- Bond chassis to vehicle ground at a single point.
- Use insulated standoffs where PCBs come near metal parts when not grounded intentionally.

Files included
- `faceplate.svg` — 1:1 printable faceplate template with cutouts and labels.
- `mounting_guide.md` — step‑by‑step template printing and drilling instructions.

If you want, I can now:
- Generate a 1:1 PDF ready for printing, or
- Produce a drilling jig (SVG with hole centers only) for CNC/laser cutting.
