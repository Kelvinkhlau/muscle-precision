#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="MusclePrecision/MusclePrecision.xcodeproj"
SCHEME="MusclePrecision"

SIMULATOR_ID="$(python3 - <<'PY'
import json
import subprocess
import sys

raw = subprocess.check_output([
    "xcrun", "simctl", "list", "devices", "available", "--json"
], text=True)

payload = json.loads(raw)

for runtime in sorted(payload.get("devices", {}).keys(), reverse=True):
    devices = payload["devices"][runtime]
    for device in devices:
        name = device.get("name", "")
        udid = device.get("udid")
        if udid and "iPhone" in name:
            print(udid)
            sys.exit(0)

sys.exit("No available iPhone simulator found")
PY
)"

echo "Using simulator id: ${SIMULATOR_ID}"

xcodebuild \
  -project "${PROJECT_PATH}" \
  -scheme "${SCHEME}" \
  -destination "platform=iOS Simulator,id=${SIMULATOR_ID}" \
  CODE_SIGNING_ALLOWED=NO \
  test
