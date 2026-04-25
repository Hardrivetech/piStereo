BOM — Vendor links & consolidated shopping list (piStereo)

Overview
- This file converts the BOM items into recommended vendors and search queries so you can quickly add items to carts. I focused on trusted suppliers: Raspberry Pi official, Digi-Key, Mouser, Adafruit, The Pi Hut, Amazon, Thomann/Sweetwater for audio gear.

How to use
- Click the vendor names or paste the search queries into the vendor site to find the exact SKU you want.
- I prioritized compatibility notes (Pi5 or automotive ratings). If you want, I can follow up and fetch specific product URLs/ASINs and produce a CSV with direct purchase links.

Core SBC
- Raspberry Pi 5 Model B (4GB or 8GB)
  - Vendor: Raspberry Pi official, Digi-Key, Mouser, Adafruit, The Pi Hut, Amazon
  - Search query: "Raspberry Pi 5 Model B 4GB" or "Raspberry Pi 5 Model B 8GB"
  - Note: prefer 8GB if you plan to run heavier apps (OpenAuto + UI)

Storage
- microSD (high-endurance) 32–128 GB
  - Vendors: Amazon, Newegg
  - Search: "Samsung PRO Endurance 64GB" or "SanDisk High Endurance 64GB"

Audio (recommended paths)
- Option A (USB multichannel interface, easiest)
  - Example: Behringer UMC404HD (USB 4-in/4-out)
  - Vendors: Thomann, Sweetwater, Amazon
  - Search: "Behringer UMC404HD"
  - Note: check outputs (TRS vs RCA) and buy TRS→RCA adapters if needed

- Option B (HAT / I2S multichannel)
  - Example: AudioInjector Octo (verify Pi 5 compatibility)
  - Vendors: AudioInjector site, The Pi Hut, HiFiBerry/Audiophonics for alternatives
  - Search: "AudioInjector Octo HAT" or "multichannel audio HAT Raspberry Pi"

- RCA panel jacks
  - Vendors: Digi-Key, Mouser
  - Search: "panel mount RCA jack" or "RCA chassis jack" (3 stereo pairs: Front, Rear, Sub)

- Shielded RCA cables & TRS→RCA adapters
  - Vendors: Amazon, Monoprice
  - Search: "shielded RCA cable 3 pair" and "TRS to RCA adapter" 

Amplification & speaker outputs
- 4-channel car amplifier (RCA inputs → speaker outputs)
  - Search: "4 channel car amplifier TDA7850" or branded compact 4-channel car amp
  - Vendors: Amazon, eBay, local car audio shops

- Speaker screw terminal blocks
  - Vendors: Digi-Key, Mouser
  - Search: "8 position speaker terminal block" or "8 position screw terminal"

Power & protection
- Automotive DC→DC buck converter 12V→5V, 6–10 A (recommended 8–10 A)
  - Vendors: Amazon, Digi-Key, Mouser
  - Search: "12V to 5V 10A buck converter automotive" or "car USB power module 10A"

- Car power controller / auto shutoff module
  - Vendors: Amazon, AliExpress, specialized car PC accessory shops
  - Search: "car power controller auto power off Raspberry Pi" or "car PC power controller"

- Inline fuse holder + fuse (10A)
  - Vendors: Auto parts stores, Amazon
  - Search: "inline fuse holder 10A automotive"

- TVS transient suppressor (SMBJ series) for VIN (optional)
  - Vendors: Digi-Key, Mouser
  - Search: "SMBJ TVS diode 30V automotive" (choose appropriate standoff voltage)

Controls & connectors
- Rotary encoder with push (detent)
  - Vendors: Adafruit, Digi-Key, Amazon
  - Search: "EC11 rotary encoder with push" or "panel rotary encoder detent"

- Momentary pushbuttons (prev/next/play/power)
  - Vendors: Digi-Key, Mouser, Amazon
  - Search: "12mm panel momentary switch" or "momentary pushbutton 12mm"

- Molex / K.K. connector housings or screw terminal blocks
  - Vendors: Digi-Key, Mouser
  - Search: "Molex KK housing 2.54mm" or "screw terminal block 2/3/4 position"

Mechanical & mounting
- Universal double-DIN mounting kit and bezel
  - Vendors: Amazon, eBay, car audio shops
  - Search: "double DIN universal mounting kit" or "double din pocket"

- Panel-mount RCA and speaker terminal panels
  - Vendors: AliExpress, Amazon, local electronics suppliers

Cables & wiring
- Shielded RCA cable set (3 pairs)
  - Vendors: Amazon, Monoprice
  - Search: "3 pair shielded RCA cable"

- TRS→RCA cables/adapters
  - Vendors: Amazon
  - Search: "TRS to RCA cable" or "TRS to RCA adapter"

- Speaker wire 14–16 AWG
  - Vendors: Home Depot, Amazon
  - Search: "14 AWG speaker wire"

- Power wire 14–12 AWG for amp, 18–16 AWG for Pi feed
  - Vendors: Auto parts stores, Amazon

Accessories & misc
- Ground loop isolator (if hum occurs)
  - Vendors: Amazon
  - Search: "ground loop isolator RCA"

- Heatsink/fan for Pi and audio interface
  - Vendors: Adafruit, Amazon
  - Search: "Raspberry Pi 5 heatsink fan" or "USB audio interface heatsink"

Estimated cost (ballpark)
- Minimal: ~$200–350
- Midrange: ~$350–650
- Higher quality: $700+

Next steps
- I can now:
  - fetch exact product pages/ASINs and produce a CSV with direct purchase links for Amazon/Digi-Key/Adafruit/Mouser (recommended), or
  - create a printable faceplate and mounting diagram.

I recommended direct vendor links first — do you want me to fetch exact product pages and produce a downloadable CSV of direct links now?