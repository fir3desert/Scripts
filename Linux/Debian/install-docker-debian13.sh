#!/usr/bin/env bash
# Docker + Docker Compose installer for Debian 13
# Installs Docker Engine, CLI, containerd and the Compose plugin
# using the official Docker APT repository.
# Run as root: sudo bash install-docker-debian13.sh

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
    printf "${CYAN}${BOLD}  ██████╗  ██████╗  ██████╗██╗  ██╗███████╗██████╗ ${R}\n"
    printf "${CYAN}${BOLD}  ██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗${R}\n"
    printf "${CYAN}${BOLD}  ██║  ██║██║   ██║██║     █████╔╝ █████╗  ██████╔╝${R}\n"
    printf "${CYAN}${BOLD}  ██║  ██║██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗${R}\n"
    printf "${CYAN}${BOLD}  ██████╔╝╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║${R}\n"
    printf "${CYAN}${BOLD}  ╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝${R}\n"
    printf "\n"
    printf "  ${CYAN}${BOLD}Docker Engine + Docker Compose installer${R}\n"
    printf "  ${GRAY}Target: Debian 13 (Trixie)${R}\n"
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
    "$@" &>/tmp/docker_setup_last_output &
    local pid=$!
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${CYAN}%s${R} %s  " "${frames[$((i % 4))]}" "$label"
        i=$((i + 1))
        sleep 0.08
    done
    wait "$pid" && { printf "\r"; ok "$label"; } || fail "$label (see /tmp/docker_setup_last_output)"
}

# Pre-flight checks
header
section "Pre-flight checks"

[[ $EUID -eq 0 ]] || fail "This script must be run as root (try: sudo bash $0)"
ok "Running as root"

ping -c1 -W3 8.8.8.8 &>/dev/null || fail "No internet connection"
ok "Internet connection available"

if grep -qi 'trixie' /etc/os-release; then
    ok "Debian 13 (Trixie) detected"
else
    info "Could not confirm Debian 13 (Trixie) in /etc/os-release, continuing anyway"
fi

TARGET_USER="${SUDO_USER:-$(getent passwd 1000 | cut -d: -f1 || true)}"
if [[ -n "$TARGET_USER" ]]; then
    printf "  ${GREEN}[OK]${R} User to add to the docker group: ${ORANGE}%s${R}\n" "$TARGET_USER"
else
    info "No target user detected; skipping docker group assignment"
fi

# Remove old versions
section "Removing old Docker packages"

export DEBIAN_FRONTEND=noninteractive

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
    apt-get remove -y "$pkg" &>/dev/null || true
done
ok "Old/conflicting packages removed (if any were present)"

# Update system and install dependencies
section "Updating package lists and installing dependencies"

spinner "apt update - refreshing package lists"     apt-get update -qq
spinner "Installing ca-certificates, curl, gnupg"   apt-get install -yq ca-certificates curl gnupg

# Add Docker's official GPG key and repository
section "Configuring the Docker APT repository"

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
ok "Docker GPG key installed"

ARCH="$(dpkg --print-architecture)"
CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"

cat > /etc/apt/sources.list.d/docker.list <<EOF
deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${CODENAME} stable
EOF
ok "Docker repository added for codename '${CODENAME}'"

spinner "apt update - refreshing package lists (Docker repo)"  apt-get update -qq

# Install Docker
section "Installing Docker Engine and Compose plugin"

PACKAGES=(
    docker-ce
    docker-ce-cli
    containerd.io
    docker-buildx-plugin
    docker-compose-plugin
)
for pkg in "${PACKAGES[@]}"; do
    spinner "Installing ${pkg}" apt-get install -yq "$pkg"
done

# Enable and start Docker
section "Enabling the Docker service"

systemctl enable --now docker &>/dev/null
systemctl is-active --quiet docker || fail "Docker service is not running"
ok "Docker service is enabled and running"

# Configure docker group
section "Configuring docker group access"

if [[ -n "$TARGET_USER" ]]; then
    usermod -aG docker "$TARGET_USER"
    printf "  ${GREEN}[OK]${R} ${ORANGE}%s${R} added to the docker group\n" "$TARGET_USER"
    info "Log out and back in (or run 'newgrp docker') to use Docker without sudo"
else
    info "No user added to the docker group; add one manually with: usermod -aG docker <user>"
fi

# Verify installation
section "Verifying installation"

DOCKER_VERSION="$(docker --version)"
COMPOSE_VERSION="$(docker compose version)"
ok "$DOCKER_VERSION"
ok "$COMPOSE_VERSION"

# Summary
printf "\n${CYAN}${LINE_DOUBLE}${R}\n"
printf "\n  ${GREEN}${BOLD}Setup completed${R}\n\n"
printf "  ${GRAY}Installed packages${R}     ${ORANGE}%s${R}\n" "${PACKAGES[*]}"
printf "  ${GRAY}Docker group user${R}      ${ORANGE}%s${R}\n" "${TARGET_USER:-none}"
printf "  ${GRAY}Finished${R}               ${GRAY}%s${R}\n" "$(date '+%Y-%m-%d %H:%M:%S')"
printf "  ${GRAY}Hostname${R}               ${GRAY}%s${R}\n" "$(hostname)"
printf "\n  ${GRAY}Try it:${R} ${YELLOW}docker run hello-world${R}\n"
printf "\n${CYAN}${LINE_DOUBLE}${R}\n\n"
