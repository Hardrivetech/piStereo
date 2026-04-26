#!/usr/bin/env bash
# install_pi_headunit.sh — full installer for the pi_headunit project
# - deploys repo to /opt/pi_headunit (configurable)
# - copies default config to /etc/pi_headunit if absent (or with --force)
# - installs Python deps if requirements.txt exists
# - enables systemd units found in systemd/
# - optionally runs audio setup and installs OpenAuto autostart (udev)

set -euo pipefail

# Defaults
PREFIX=/opt/pi_headunit
CONFIG_DIR=/etc/pi_headunit
SYSTEMD_DIR=/etc/systemd/system
DRY_RUN=0
SKIP_UDEV=0
SKIP_AUDIO=0
FORCE_CONFIG=0
USER_NAME=pi
NO_CREATE_USER=0
CREATE_SERVICE_USER=0
YES=0
PASSWORD=""
PASSWORD_FILE=""

# Logging
LOG_DIR=/var/log/pi_headunit
LOG_FILE=$LOG_DIR/install.log
LOGROTATE_CONF=/etc/logrotate.d/pi_headunit

usage() {
  cat <<EOF
Usage: $0 [--prefix PATH] [--user USER] [--dry-run] [--skip-udev] [--skip-audio] [--force-config] [-h]
  --prefix PATH     Install prefix (default: /opt/pi_headunit)
  --user USER       Owner user for deployed files (default: pi)
  --create-service-user  Explicitly create the service user if missing
  --no-create-user  Do NOT create the service user
  --dry-run         Print actions without making changes
  --yes, -y         Generate and set a random password for service user
  --password PWD    Set the service user password noninteractively (use with caution)
  --password-file FILE  Read password from FILE (safer than CLI arg)
  --skip-udev       Do not install OpenAuto udev rules
  --skip-audio      Do not run audio setup helper
  --force-config    Overwrite /etc/pi_headunit/config.ini if present
  -h|--help         Show this help
EOF
}

# simple arg parse
while [ "$#" -gt 0 ]; do
  case "$1" in
    --prefix) PREFIX="$2"; shift 2;;
    --user) USER_NAME="$2"; shift 2;;
    --create-service-user) CREATE_SERVICE_USER=1; shift;;
    --no-create-user) NO_CREATE_USER=1; shift;;
    --dry-run) DRY_RUN=1; shift;;
    --yes|-y) YES=1; shift;;
    --password) PASSWORD="$2"; shift 2;;
    --password-file) PASSWORD_FILE="$2"; shift 2;;
    --skip-udev) SKIP_UDEV=1; shift;;
    --skip-audio) SKIP_AUDIO=1; shift;;
    --force-config) FORCE_CONFIG=1; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

# Ensure running under bash
if [ -z "${BASH_VERSION:-}" ]; then
  echo "This script requires bash. Run with: bash $0" >&2
  exit 2
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Sudo helper
SUDO=''
if [ "$(id -u)" -ne 0 ]; then
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[DRY-RUN] would ensure log directory $LOG_DIR exists"
  else
    if command -v sudo >/dev/null 2>&1; then
      SUDO='sudo'
    else
      echo "This script needs root. Run as root or install sudo." >&2
      exit 1
    fi
  fi
else
  SUDO=''
fi

run() {
  # stringify command for logging
  cmd_str=$(printf '%q ' "$@")
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[DRY-RUN] $cmd_str"
    if [ -n "$SUDO" ]; then
      $SUDO bash -c "echo \"$(date -u +%Y-%m-%dT%H:%M:%SZ) [DRY-RUN] $cmd_str\" >> '$LOG_FILE'"
    else
      echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) [DRY-RUN] $cmd_str" >> "$LOG_FILE" || true
    fi
  else
    if [ -n "$SUDO" ]; then
      # log then run
      $SUDO bash -c "echo \"$(date -u +%Y-%m-%dT%H:%M:%SZ) RUN: $cmd_str\" >> '$LOG_FILE'"
      if command -v logger >/dev/null 2>&1; then
        $SUDO logger -t pi_headunit-installer "RUN: $cmd_str" || true
      fi
      $SUDO "$@"
    else
      echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) RUN: $cmd_str" >> "$LOG_FILE" || true
      if command -v logger >/dev/null 2>&1; then
        logger -t pi_headunit-installer "RUN: $cmd_str" || true
      fi
      "$@"
    fi
  fi
}

echo "pi_headunit installer"
echo "Repo root: $REPO_ROOT"
echo "Install prefix: $PREFIX"
echo "Config dir: $CONFIG_DIR"

# Ensure prefix exists and rsync repo
echo "Deploying project to $PREFIX (idempotent)"
if command -v rsync >/dev/null 2>&1; then
  run mkdir -p "$PREFIX"
  run rsync -a --delete --exclude='.git' "$REPO_ROOT/" "$PREFIX/"
else
  echo "rsync not found — falling back to copy (less efficient)"
  run mkdir -p "$PREFIX"
  if [ -d "$PREFIX" ]; then
    run mv "$PREFIX" "${PREFIX}.bak" || true
  fi
  run mkdir -p "$PREFIX"
  run cp -a "$REPO_ROOT/." "$PREFIX/"
fi

# Ensure the target service user exists (create if missing)
if [ "$NO_CREATE_USER" -eq 1 ]; then
  echo "Skipping service user creation (--no-create-user set)."
  run echo "Skipping service user creation (--no-create-user)"
else
    if id -u "$USER_NAME" >/dev/null 2>&1; then
      echo "Using existing user $USER_NAME"
      run echo "Using existing user $USER_NAME"
    else
      if [ "$CREATE_SERVICE_USER" -eq 1 ]; then
        echo "Creating service user $USER_NAME (explicit --create-service-user)"
      else
        echo "Creating service user $USER_NAME"
      fi
      if [ "$DRY_RUN" -eq 1 ]; then
        echo "[DRY-RUN] would create user $USER_NAME"
        echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) [DRY-RUN] would create user $USER_NAME" >> "$LOG_FILE" || true
      else
        if command -v adduser >/dev/null 2>&1; then
          run adduser --disabled-password --gecos "" "$USER_NAME"
        else
          run useradd -r -m -s /usr/sbin/nologin "$USER_NAME"
        fi
      fi
    fi
fi

# Ownership
# If requested, set the service user's password noninteractively.
# Supports: --password PWD, --password-file FILE, or --yes to generate a random password.
if [ "$NO_CREATE_USER" -eq 0 ]; then
  # load password from file if provided
  if [ -n "$PASSWORD_FILE" ]; then
    if [ -f "$PASSWORD_FILE" ]; then
      PASSWORD="$(cat "$PASSWORD_FILE")"
    else
      echo "Password file not found: $PASSWORD_FILE" >&2
      exit 1
    fi
  fi

  if [ -n "$PASSWORD" ]; then
    echo "Setting password for $USER_NAME (noninteractive)"
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "[DRY-RUN] would set password for $USER_NAME"
    else
      if [ -n "$SUDO" ]; then
        echo "$USER_NAME:$PASSWORD" | $SUDO chpasswd
      else
        echo "$USER_NAME:$PASSWORD" | chpasswd
      fi
      run echo "Set password for $USER_NAME"
    fi
  elif [ "$YES" -eq 1 ]; then
    echo "Generating random password for $USER_NAME"
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "[DRY-RUN] would generate and set random password for $USER_NAME"
    else
      RANDPW=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 16)
      if [ -n "$SUDO" ]; then
        echo "$USER_NAME:$RANDPW" | $SUDO chpasswd
      else
        echo "$USER_NAME:$RANDPW" | chpasswd
      fi
      echo "Generated password for $USER_NAME: $RANDPW"
      run echo "Generated random password for $USER_NAME (not logged)"
    fi
  fi
fi

echo "Setting ownership to $USER_NAME:$USER_NAME"
run chown -R "$USER_NAME":"$USER_NAME" "$PREFIX" || true

  if [ -n "$SUDO" ]; then
    $SUDO mkdir -p "$LOG_DIR" || true
    $SUDO touch "$LOG_FILE" || true
    $SUDO chown root:root "$LOG_DIR" || true
    $SUDO chmod 755 "$LOG_DIR" || true
  else
    mkdir -p "$LOG_DIR" || true
    touch "$LOG_FILE" || true
  fi

# Install logrotate configuration for installer log
echo "Installing logrotate configuration for $LOG_FILE"
if [ "$DRY_RUN" -eq 1 ]; then
  echo "[DRY-RUN] would install logrotate config to $LOGROTATE_CONF"
else
  if [ -n "$SUDO" ]; then
    $SUDO bash -c "cat > '$LOGROTATE_CONF' <<'LR'
$LOG_FILE {
    weekly
    rotate 4
    compress
    missingok
    notifempty
    create 0644 root root
}
LR"
    $SUDO chmod 644 "$LOGROTATE_CONF" || true
  else
    cat > "$LOGROTATE_CONF" <<'LR'
$LOG_FILE {
    weekly
    rotate 4
    compress
    missingok
    notifempty
    create 0644 root root
}
LR
    chmod 644 "$LOGROTATE_CONF" || true
  fi
fi

# Create config dir and copy default config if needed
run mkdir -p "$CONFIG_DIR"
if [ -f "$CONFIG_DIR/config.ini" ] && [ "$FORCE_CONFIG" -ne 1 ]; then
  echo "Config exists at $CONFIG_DIR/config.ini (use --force-config to overwrite)"
else
  if [ -f "$REPO_ROOT/config/config.ini" ]; then
    echo "Copying default config to $CONFIG_DIR/config.ini"
    run cp "$REPO_ROOT/config/config.ini" "$CONFIG_DIR/config.ini"
    run chown "$USER_NAME":"$USER_NAME" "$CONFIG_DIR/config.ini" || true
  else
    echo "No default config found in repo (config/config.ini)"
  fi
fi

# Install Python deps if requirements.txt present
if [ -f "$REPO_ROOT/requirements.txt" ]; then
  echo "Installing Python requirements from requirements.txt"
  run pip3 install -r "$REPO_ROOT/requirements.txt"
else
  echo "No requirements.txt found — skipping pip install"
fi

# Install systemd units
if [ -d "$REPO_ROOT/systemd" ]; then
  echo "Installing systemd units from $REPO_ROOT/systemd"
  for svc in "$REPO_ROOT"/systemd/*.service; do
    [ -e "$svc" ] || continue
    svcname=$(basename "$svc")
    echo " - installing $svcname"
    run cp "$svc" "$SYSTEMD_DIR/$svcname"
  done
  run systemctl daemon-reload
  # enable common units if present
  if [ -f "$SYSTEMD_DIR/pi_headunit.service" ] || [ -f "$PREFIX/systemd/pi_headunit.service" ]; then
    echo "Enabling pi_headunit.service"
    run systemctl enable --now pi_headunit.service || true
  fi
  if [ -f "$SYSTEMD_DIR/pi_headunit_display.service" ] || [ -f "$PREFIX/systemd/pi_headunit_display.service" ]; then
    echo "Enabling pi_headunit_display.service"
    run systemctl enable --now pi_headunit_display.service || true
  fi
fi

# Audio setup helper (optional)
if [ "$SKIP_AUDIO" -eq 0 ] && [ -x "$REPO_ROOT/scripts/setup_audio.sh" ]; then
  echo "Running audio setup helper"
  run bash "$REPO_ROOT/scripts/setup_audio.sh"
else
  echo "Skipping audio setup helper"
fi

# OpenAuto autostart: prefer udev installer if present
if [ "$SKIP_UDEV" -eq 0 ]; then
  if [ -x "$REPO_ROOT/scripts/install_openauto_udev.sh" ]; then
    echo "Installing OpenAuto udev rules"
    run bash "$REPO_ROOT/scripts/install_openauto_udev.sh"
  elif [ -x "$REPO_ROOT/scripts/install_openauto_monitor.sh" ]; then
    echo "Installing OpenAuto polling monitor"
    run bash "$REPO_ROOT/scripts/install_openauto_monitor.sh"
  else
    echo "No OpenAuto installer scripts found; skipping"
  fi
else
  echo "Skipping OpenAuto autostart setup"
fi

# Final notes
echo "Installation complete (dry-run=$DRY_RUN)."
if [ "$DRY_RUN" -eq 1 ]; then
  echo "Dry-run mode — no changes were made. Re-run without --dry-run to perform the install."
else
  echo "Verify services:"
  echo "  systemctl status pi_headunit.service"
  echo "  systemctl status pi_headunit_display.service"
  echo "Edit configs at: $CONFIG_DIR/config.ini"
fi
