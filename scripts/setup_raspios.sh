#!/usr/bin/env bash
# Automated setup for Raspberry Pi OS Desktop for piStereo
# - creates `pi` service account (if missing)
# - enables LightDM autologin for `pi`
# - installs common packages
# - runs the repo audio setup helper
# - deploys the repo to /opt/pi_headunit and enables the display service

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

DRY_RUN=0
SKIP_UDEV=0

usage() {
  cat <<EOF
Usage: $0 [--dry-run] [--skip-udev] [-h|--help]
  --dry-run       Print actions without making changes
  --skip-udev     Don't install OpenAuto udev rules
  -h|--help       Show this help
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift;;
    --skip-udev) SKIP_UDEV=1; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1"; usage; exit 1;;
  esac
done

if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO='sudo'
  else
    echo "This script needs root. Run as root or install sudo." >&2
    exit 1
  fi
else
  SUDO=''
fi

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[DRY-RUN]" "$@"
  else
    if [ -n "$SUDO" ]; then
      $SUDO "$@"
    else
      "$@"
    fi
  fi
}

echo "Repository root: $REPO_ROOT"
if [ "$DRY_RUN" -eq 1 ]; then echo "DRY RUN enabled: no changes will be made"; fi
if [ "$SKIP_UDEV" -eq 1 ]; then echo "Skipping udev rules installation"; fi

# Create 'pi' user if it doesn't exist
if id -u pi >/dev/null 2>&1; then
  echo "User 'pi' already exists"
else
  echo "Creating user 'pi' (disabled password). Set a password later with: sudo passwd pi"
  run adduser --disabled-password --gecos "" pi
  run usermod -aG sudo pi || true
fi

# Add typical groups if they exist on the system
extra_groups=(adm audio video input gpio i2c spi plugdev render dialout)
for g in "${extra_groups[@]}"; do
  if getent group "$g" >/dev/null 2>&1; then
    echo "Adding 'pi' to group: $g"
    run usermod -aG "$g" pi || true
  fi
done

# Configure LightDM autologin if present
if [ -d /etc/lightdm ]; then
  echo "Configuring LightDM autologin for 'pi' (creates /etc/lightdm/lightdm.conf.d/50-autologin.conf)"
  run mkdir -p /etc/lightdm/lightdm.conf.d
  run bash -c 'cat > /etc/lightdm/lightdm.conf.d/50-autologin.conf <<EOF
[Seat:*]
autologin-user=pi
autologin-user-timeout=0
EOF'
fi

# Install packages
pkg_list=(python3 python3-pip git xserver-xorg x11-xserver-utils xinput xinput-calibrator \
  alsa-utils pavucontrol playerctl bluez bluez-tools pipewire wireplumber libspa-0.2-bluetooth rsync)
echo "Updating apt and installing packages: ${pkg_list[*]}"
if [ "$DRY_RUN" -eq 1 ]; then
  echo "[DRY-RUN] apt update && apt install -y ${pkg_list[*]}"
else
  run apt update
  run apt install -y "${pkg_list[@]}"
fi

# Run audio helper if present
if [ -x "$REPO_ROOT/scripts/setup_audio.sh" ]; then
  echo "Running audio setup helper..."
  run bash "$REPO_ROOT/scripts/setup_audio.sh"
fi

# Deploy project to /opt/pi_headunit
DEST="/opt/pi_headunit"
echo "Deploying project to $DEST (idempotent)"
if command -v rsync >/dev/null 2>&1; then
  echo "Using rsync to sync repo -> $DEST"
  run mkdir -p "$DEST"
  run rsync -a --delete --exclude='.git' "$REPO_ROOT/" "$DEST/"
else
  echo "rsync not found; falling back to safe backup + copy"
  if [ -d "$DEST" ]; then
    echo "Existing $DEST found; moving to ${DEST}.bak"
    run mv "$DEST" "${DEST}.bak"
  fi
  run mkdir -p "$DEST"
  run cp -a "$REPO_ROOT/." "$DEST/"
fi
# fix ownership
run chown -R pi:pi "$DEST" || true

# Enable display service
echo "Enabling display service: pi_headunit_display.service"
run systemctl daemon-reload
run systemctl enable --now pi_headunit_display.service || true

# Install udev rules unless skipped
if [ "$SKIP_UDEV" -ne 1 ]; then
  if [ -x "$REPO_ROOT/scripts/install_openauto_udev.sh" ]; then
    echo "Installing OpenAuto udev rules..."
    run bash "$REPO_ROOT/scripts/install_openauto_udev.sh"
  else
    echo "Udev installer not found; skipping udev install"
  fi
fi

echo "Setup finished."
if [ "$DRY_RUN" -eq 1 ]; then
  echo "Dry-run complete; no changes made."
else
  echo "Set a password for 'pi' now: sudo passwd pi"
fi
