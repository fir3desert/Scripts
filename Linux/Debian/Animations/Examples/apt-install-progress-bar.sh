#!/usr/bin/env bash
# Example: install packages with a package-count progress bar.

set -euo pipefail

R="\033[0m"
GREEN="\033[38;5;83m"
LOG_FILE="/tmp/apt-install-progress-bar.log"
PACKAGES=(vim curl git)

fail() { printf "\n  [ERROR] %s\n" "$1" >&2; exit 1; }

progress_bar() {
    local completed="$1"
    local total="$2"
    local width=30
    local percent=$((completed * 100 / total))
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    printf "\r  Installing packages [%-${filled}s%-${empty}s] %3d%%" \
        "$(printf '=%.0s' $(seq 1 "$filled"))" \
        "$(printf ' %.0s' $(seq 1 "$empty"))" "$percent"
}

[[ $EUID -eq 0 ]] || fail "Run this example as root or with sudo"
printf "\nAPT install with progress-bar animation\n\n"

completed=0
total=${#PACKAGES[@]}
for package in "${PACKAGES[@]}"; do
    apt-get install -yq "$package" >"$LOG_FILE" 2>&1 &
    pid=$!
    while kill -0 "$pid" 2>/dev/null; do
        progress_bar "$completed" "$total"
        sleep 0.2
    done
    wait "$pid" || fail "Installing ${package} failed (see $LOG_FILE)"
    completed=$((completed + 1))
    progress_bar "$completed" "$total"
done

printf " ${GREEN}[OK]${R}\n"
