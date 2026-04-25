#!/bin/bash
set -e
OUT=/var/log/pi_headunit_smoketest.last.json
python3 /opt/pi_headunit/src/smoketest.py | tee "$OUT"
RC=${PIPESTATUS[0]}
if [ $RC -ne 0 ]; then
  echo "Smoketest failed (code $RC). See $OUT"
  exit $RC
else
  echo "Smoketest passed"
  exit 0
fi
