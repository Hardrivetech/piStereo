#!/usr/bin/env bash
# Wrapper to prefer an installed virtualenv python under the project's prefix
# Usage: run_python.sh /path/to/script.py [args...]

PREFIX="/opt/pi_headunit"
PY="$PREFIX/venv/bin/python"

if [ -x "$PY" ]; then
  exec "$PY" "$@"
else
  exec /usr/bin/python3 "$@"
fi
