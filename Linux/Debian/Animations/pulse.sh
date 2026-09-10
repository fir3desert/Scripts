#!/usr/bin/env bash
# Pulse animation preview

set -euo pipefail

R="\033[0m"
GREEN="\033[38;5;83m"

pulse() {
    local label="$1"
    local duration="$2"
    local frames=('[    ]' '[=   ]' '[==  ]' '[=== ]' '[====]' '[ ===]' '[  ==]' '[   =]')
    local frame=0
    local end_time=$((SECONDS + duration))

    while ((SECONDS < end_time)); do
        printf "\r  %s %s" "$label" "${frames[$frame]}"
        frame=$(((frame + 1) % ${#frames[@]}))
        sleep 0.2
    done

    printf "\r  %s ${GREEN}[OK]${R}\n" "$label"
}

printf "\nPulse animation preview\n\n"
pulse "Working" 6

printf "\nPreview completed.\n\n"
