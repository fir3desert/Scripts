#!/usr/bin/env bash
# Progress bar animation preview

set -euo pipefail

R="\033[0m"
CYAN="\033[38;5;87m"
GREEN="\033[38;5;83m"

progress_bar() {
    local label="$1"
    local duration="$2"
    local width=30
    local steps=100
    local delay

    delay=$(awk "BEGIN { printf \"%.3f\", ${duration}/${steps} }")

    for ((percent = 0; percent <= steps; percent++)); do
        local filled=$((percent * width / steps))
        local empty=$((width - filled))
        printf "\r  %s%-${filled}s\033[90m%-${empty}s${R} %3d%%" \
            "$label [" "$(printf '%0.s=' $(seq 1 "$filled"))" \
            "$(printf '%0.s ' $(seq 1 "$empty"))" "$percent"
        sleep "$delay"
    done

    printf " ${GREEN}[OK]${R}\n"
}

printf "\nProgress bar animation preview\n\n"
progress_bar "Downloading" 4
progress_bar "Installing " 6

printf "\nPreview completed.\n\n"
