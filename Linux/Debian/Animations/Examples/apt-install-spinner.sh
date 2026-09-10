#!/usr/bin/env bash
# Example: install packages with a spinner animation

set -euo pipefail

R="\033[0m"
GREEN="\033[38;5;83m"

ok() {
    printf "  ${GREEN}[OK]${R} %s\n" "$1"
}

fail() {
    printf "\n  [ERROR] %s\n" "$1" >&2
    exit 1
}

spinner() {
    local label="$1"
    shift
    local frames=('-' '\' '|' '/')
    local frame=0
    local output_file="/tmp/apt-install-spinner.log"

    "$@" >"$output_file" 2>&1 &
    local pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  %s %s  " "${frames[$((frame % 4))]}" "$label"
        frame=$((frame + 1))
        sleep 0.08
    done

    if wait "$pid"; then
        printf "\r"
        ok "$label"
    else
        printf "\n"
        fail "$label failed (see $output_file)"
    fi
}

[[ $EUID -eq 0 ]] || fail "Run this example as root or with sudo"

PACKAGES=(vim curl git)

printf "\nAPT install animation example\n\n"

for package in "${PACKAGES[@]}"; do
    spinner "Installing ${package}" apt-get install -yq "$package"
done

printf "\nInstalled packages: %s\n\n" "${PACKAGES[*]}"
