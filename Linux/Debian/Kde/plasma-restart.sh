#!/usr/bin/env bash

set -euo pipefail

echo "Restarting KDE Plasma GUI..."

# Restart the Plasma shell without the complex environment detection
pkill -x plasmashell || true
sleep 2

# Restart the shell in the current desktop session
if command -v kstart5 >/dev/null 2>&1; then
    kstart5 plasmashell >/dev/null 2>&1 &
else
    plasmashell >/dev/null 2>&1 &
fi

sleep 2

if pgrep -x plasmashell >/dev/null; then
    echo "KDE Plasma GUI restarted successfully."
else
    echo "Plasma shell did not restart correctly."
    exit 1
fi
