#!/usr/bin/env bash
# Loading animation preview

set -euo pipefail

R="\033[0m"
GREEN="\033[38;5;83m"

loading() {
    local label="$1"
    local duration="$2"
    local frames=('   ' '.  ' '.. ' '...')
    local frame=0
    local end_time=$((SECONDS + duration))

    while ((SECONDS < end_time)); do
        printf "\r  %s%s" "$label" "${frames[$frame]}"
        frame=$(((frame + 1) % 4))
        sleep 0.45
    done

    printf "\r  ${GREEN}%s... [OK]${R}\n" "$label"
}

printf "\nLoading animation preview\n\n"
loading "Loading" 6

printf "\nPreview completed.\n\n"
