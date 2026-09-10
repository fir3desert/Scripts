#!/usr/bin/env bash
# Debian 13 homelab VM quick setup
# Updates a new VM, installs SSH and common administration tools,
# and grants sudo access to the user with UID 1000.
# Run as root: sudo bash debian13-setup.sh

set -euo pipefail

# Colors
R="\033[0m"
BOLD="\033[1m"
CYAN="\033[38;5;87m"
GREEN="\033[38;5;83m"
YELLOW="\033[38;5;220m"
RED="\033[38;5;203m"
BLUE="\033[38;5;39m"
GRAY="\033[38;5;245m"
ORANGE="\033[38;5;215m"

# Separators
LINE_SINGLE="  ────────────────────────────────────────────────────────"
LINE_DOUBLE="  ════════════════════════════════════════════════════════"

# Helpers
header() {
    clear
    printf "\n"
    printf "${CYAN}${LINE_DOUBLE}${R}\n"
    printf "${CYAN}${BOLD}  ██████╗ ███████╗██████╗ ██╗ █████╗ ███╗   ██╗${R}\n"
    printf "${CYAN}${BOLD}  ██╔══██╗██╔════╝██╔══██╗██║██╔══██╗████╗  ██║${R}\n"
    printf "${CYAN}${BOLD}  ██║  ██║█████╗  ██████╔╝██║███████║██╔██╗ ██║${R}\n"
    printf "${CYAN}${BOLD}  ██║  ██║██╔══╝  ██╔══██╗██║██╔══██║██║╚██╗██║${R}\n"
    printf "${CYAN}${BOLD}  ██████╔╝███████╗██████╔╝██║██║  ██║██║ ╚████║${R}\n"
    printf "${CYAN}${BOLD}  ╚═════╝ ╚══════╝╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝${R}\n"
    printf "\n"
    printf "  ${CYAN}${BOLD}Debian 13 server setup${R}\n"
    printf "  ${GRAY}Made by fir3${R}\n"
    printf "  ${GRAY}Started: $(date '+%Y-%m-%d %H:%M')${R}\n"
    printf "${CYAN}${LINE_DOUBLE}${R}\n"
}

section() {
    printf "\n${GRAY}${LINE_SINGLE}${R}\n"
    printf "  ${BLUE}${BOLD}%s${R}\n" "$1"
    printf "${GRAY}${LINE_SINGLE}${R}\n"
}

ok()   { printf "  ${GREEN}[OK]${R} %s\n" "$1"; }
info() { printf "  ${YELLOW}[INFO]${R} %s\n" "$1"; }
fail() { printf "\n  ${RED}[ERROR]${R} %s\n" "$1" >&2; exit 1; }

spinner() {
    local label="$1"; shift
    local frames=('-' '\' '|' '/')
    local i=0
    "$@" &>/tmp/setup_last_output &
    local pid=$!
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${CYAN}%s${R} %s  " "${frames[$((i % 4))]}" "$label"
        i=$((i + 1))
        sleep 0.08
    done
    wait "$pid" && { printf "\r"; ok "$label"; } || fail "$label (see /tmp/setup_last_output)"
}

# Pre-flight checks
header
section "Pre-flight checks"

[[ $EUID -eq 0 ]] || fail "This script must be run as root (try: sudo bash $0)"
ok "Running as root"

ping -c1 -W3 8.8.8.8 &>/dev/null || fail "No internet connection"
ok "Internet connection available"

TARGET_USER=$(getent passwd 1000 | cut -d: -f1 || true)
[[ -n "$TARGET_USER" ]] || fail "No user with UID 1000 was found"
printf "  ${GREEN}[OK]${R} User found: ${ORANGE}%s${R}\n" "$TARGET_USER"

# Update the system
section "Updating the system"

export DEBIAN_FRONTEND=noninteractive

spinner "apt update - refreshing package lists"       apt-get update -qq
spinner "apt upgrade - upgrading packages"            apt-get upgrade -yq
spinner "apt dist-upgrade - applying full upgrade"    apt-get dist-upgrade -yq
spinner "apt autoremove - removing unused packages"   apt-get autoremove -yq
spinner "apt autoclean - cleaning the cache"          apt-get autoclean -q

# Install basic packages and SSH
section "Installing basic packages and SSH"

PACKAGES=(
    openssh-server
    sudo
    curl
    wget
    vim
    tmux
    htop
    btop
    unzip
    fzf
    
)
for pkg in "${PACKAGES[@]}"; do
    spinner "Installing ${pkg}" apt-get install -yq "$pkg"
done

# Enable SSH for remote administration
section "Configuring SSH"

systemctl enable --now ssh
systemctl is-active --quiet ssh || fail "SSH service is not running"
ok "SSH service is enabled and running"

# Configure sudo
section "Configuring sudo access"

if ! getent group sudo &>/dev/null; then
    groupadd sudo
fi
ok "sudo group is available"

usermod -aG sudo "$TARGET_USER"
printf "  ${GREEN}[OK]${R} ${ORANGE}%s${R} added to the sudo group\n" "$TARGET_USER"

SUDOERS_LINE="${TARGET_USER} ALL=(ALL:ALL) ALL"
if ! grep -qF "$SUDOERS_LINE" /etc/sudoers 2>/dev/null; then
    echo "$SUDOERS_LINE" | EDITOR='tee -a' visudo &>/dev/null
fi
ok "sudoers configuration updated"

# Summary
printf "\n${CYAN}${LINE_DOUBLE}${R}\n"
printf "\n  ${GREEN}${BOLD}Setup completed${R}\n\n"
printf "  ${GRAY}System updated${R}         ${GREEN}[OK]${R}\n"
printf "  ${GRAY}Installed packages${R}     ${ORANGE}%s${R}\n" "${PACKAGES[*]}"
printf "  ${GRAY}Sudo user${R}              ${ORANGE}%s${R} ${GRAY}(UID 1000)${R}\n" "$TARGET_USER"
printf "  ${GRAY}Finished${R}               ${GRAY}%s${R}\n" "$(date '+%Y-%m-%d %H:%M:%S')"
printf "  ${GRAY}Hostname${R}               ${GRAY}%s${R}\n" "$(hostname)"
printf "\n${CYAN}${LINE_DOUBLE}${R}\n\n"
