#!/usr/bin/env bash
# Example: install packages with a pulse animation.

set -euo pipefail

R="\033[0m"
GREEN="\033[38;5;83m"
LOG_FILE="/tmp/apt-install-pulse.log"
PACKAGES=(vim curl git)

fail() { printf "\n  [ERROR] %s\n" "$1" >&2; exit 1; }

pulse() {
    local label="$1"; shift
    local frames=('[    ]' '[=   ]' '[==  ]' '[=== ]' '[====]' '[ ===]' '[  ==]' '[   =]')
    local frame=0
    "$@" >"$LOG_FILE" 2>&1 &
    local pid=$!
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  %s %s" "$label" "${frames[$frame]}"
        frame=$(((frame + 1) % ${#frames[@]})); sleep 0.2
    done
    if wait "$pid"; then
        printf "\r  ${GREEN}[OK]${R} %s\n" "$label"
    else
        fail "$label failed (see $LOG_FILE)"
    fi
}

[[ $EUID -eq 0 ]] || fail "Run this example as root or with sudo"
printf "\nAPT install with pulse animation\n\n"
for package in "${PACKAGES[@]}"; do
    pulse "Installing ${package}" apt-get install -yq "$package"
done
