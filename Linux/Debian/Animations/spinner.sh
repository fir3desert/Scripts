#!/usr/bin/env bash
# Spinner animation preview

set -euo pipefail

# Colors
R="\033[0m"
CYAN="\033[38;5;87m"
GREEN="\033[38;5;83m"
RED="\033[38;5;203m"

ok()   { printf "  ${GREEN}[OK]${R} %s\n" "$1"; }
fail() { printf "\n  ${RED}[ERROR]${R} %s\n" "$1" >&2; exit 1; }

spinner() {
    local label="$1"; shift
    local frames=('-' '\' '|' '/')
    local i=0
    "$@" &>/tmp/spinner_preview_output &
    local pid=$!
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${CYAN}%s${R} %s  " "${frames[$((i % 4))]}" "$label"
        i=$((i + 1))
        sleep 0.08
    done
    wait "$pid" && { printf "\r"; ok "$label"; } || fail "$label (see /tmp/spinner_preview_output)"
}

printf "\nSpinner animation preview\n\n"
spinner "Short task" sleep 2
spinner "Longer task" sleep 5

printf "\nPreview completed.\n\n"
