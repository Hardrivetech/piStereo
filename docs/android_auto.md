Android Auto on Raspberry Pi — options & recommendations

Short summary
- Android Auto is proprietary and the most practical options for a Raspberry Pi headunit are:
  1. OpenAuto Pro (commercial, polished)
  2. OpenAuto (open-source, community project)
  3. Run a full Android build for Pi (complex, not recommended for most builds)

1) OpenAuto Pro (recommended for reliability)
- Commercial product with an installer and documentation; integrates well with touch, Bluetooth, and USB audio routing.
- Pros: stable, actively maintained, good UX, supports Google Maps/AA features.
- Cons: paid license.
- Integration notes: set PipeWire/Pulse to route audio to your system sink; configure touch input and screen resolution per OpenAuto Pro docs.

2) OpenAuto (open-source)
- Community project that implements Android Auto head unit protocol.
- Pros: free, customizable.
- Cons: can require manual builds and tweaks; may not support the latest phones or features.
- Quick setup outline (high level):
  - Install dependencies (build-essential, cmake, libav, libusb, libasound, etc.)
  - Clone the repo and build with CMake
  - Configure systemd service to start OpenAuto at boot
  - Configure audio routing (Pulse/ALSA/PipeWire) so media from Android routes to your amp/speakers

3) Running Android OS on Pi
- Install an Android image for Pi and run Android Auto natively — this is effectively a full Android headunit, but driver/hardware support is variable.

USB vs Bluetooth Android Auto
- Android Auto primarily works over USB (MTP/ADB/Accessory protocols). Bluetooth is used for phone calls, not for full AA.
- Ensure your Pi's USB ports can be used by the headunit software; some projects require USB gadget/emulation or special permissions.

Recommendation
- If you want a low-friction, supported experience: purchase OpenAuto Pro and follow its install guide (quickest path to Android Auto on Raspberry Pi).
- If you prefer open-source and are comfortable debugging: try OpenAuto (community), but expect more manual setup.

Next steps I can take
- If you want, I can add step-by-step install guidance for OpenAuto (open-source) here and add a `systemd` service example, or
- I can add notes linking OpenAuto Pro installation steps (if you have a licence) and show how to route PipeWire audio and touch input.
