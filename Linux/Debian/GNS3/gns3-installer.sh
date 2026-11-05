#!/usr/bin/env bash
# GNS3 server quick setup for Debian 13
# Installs GNS3 (server + GUI) in a Python venv and builds ubridge, dynamips and vpcs.
#
# Run as a NORMAL user (it uses sudo only where needed): bash gns3-setup.sh
#
# Install directory:
#   - 1st run without GNS3_DIR exported: the script asks you to export it and exits.
#   - Any later run without GNS3_DIR exported: installs in $HOME/GNS3.
#   - With GNS3_DIR exported: installs there.
#       export GNS3_DIR=/path/you/want && bash gns3-setup.sh

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

# State
MARKER="$HOME/.gns3_setup_prompted"
LOG="/tmp/gns3_setup_${USER}.log"   # per-user, so it never clashes with a root-owned file
rm -f "$LOG" 2>/dev/null || true
: > "$LOG" || { printf "  [ERROR] Cannot write log file %s\n" "$LOG" >&2; exit 1; }

# Helpers
header() {
    clear
    printf "\n"
    printf "${CYAN}${LINE_DOUBLE}${R}\n"
    printf "${CYAN}${BOLD}   ██████╗ ███╗   ██╗███████╗██████╗ ${R}\n"
    printf "${CYAN}${BOLD}  ██╔════╝ ████╗  ██║██╔════╝╚════██╗${R}\n"
    printf "${CYAN}${BOLD}  ██║  ███╗██╔██╗ ██║███████╗ █████╔╝${R}\n"
    printf "${CYAN}${BOLD}  ██║   ██║██║╚██╗██║╚════██║ ╚═══██╗${R}\n"
    printf "${CYAN}${BOLD}  ╚██████╔╝██║ ╚████║███████║██████╔╝${R}\n"
    printf "${CYAN}${BOLD}   ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═════╝ ${R}\n"
    printf "\n"
    printf "  ${CYAN}${BOLD}GNS3 server setup${R}\n"
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
    local frames=('-' '\\' '|' '/')
    local i=0
    "$@" &>"$LOG" &
    local pid=$!
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${CYAN}%s${R} %s  " "${frames[$((i % 4))]}" "$label"
        i=$((i + 1))
        sleep 0.08
    done
    wait "$pid" && { printf "\r"; ok "$label"; } || fail "$label (see $LOG)"
}

# Build / install steps (run inside spinner, so they live in their own subshell)

# Clone a repo, or update it if it already exists
clone_or_update() {
    local url="$1" dest="$2"
    if [[ -d "$dest/.git" ]]; then
        git -C "$dest" pull --ff-only
    else
        git clone "$url" "$dest"
    fi
}

build_ubridge() {
    clone_or_update https://github.com/GNS3/ubridge.git "$SRC_DIR/ubridge"
    cd "$SRC_DIR/ubridge"
    make
    sudo make install
    # Lets ubridge handle network interfaces without running as root
    sudo setcap cap_net_admin,cap_net_raw=ep "$(command -v ubridge)"
}

build_dynamips() {
    clone_or_update https://github.com/GNS3/dynamips.git "$SRC_DIR/dynamips"
    mkdir -p "$SRC_DIR/dynamips/build"
    cd "$SRC_DIR/dynamips/build"
    cmake ..
    make -j"$(nproc)"
    sudo make install
}

build_vpcs() {
    clone_or_update https://github.com/GNS3/vpcs.git "$SRC_DIR/vpcs"
    cd "$SRC_DIR/vpcs/src"
    ./mk.sh
    sudo cp vpcs /usr/local/bin/
}

pip_install() {
    # shellcheck disable=SC1091
    source "$VENV_DIR/bin/activate"
    "$@"
}

# Pre-flight checks
header
section "Pre-flight checks"

[[ $EUID -ne 0 ]] || fail "Do not run this script as root. Run it as your normal user: bash $0"
ok "Running as normal user: $USER"

command -v sudo &>/dev/null || fail "sudo is not installed (install it as root and add your user to the sudo group)"
info "sudo password may be requested"
sudo -v || fail "Could not get sudo privileges"
# Keep the sudo timestamp alive while the script runs
( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) &>/dev/null &
SUDO_KEEPALIVE=$!
trap 'kill "$SUDO_KEEPALIVE" 2>/dev/null || true' EXIT
ok "sudo privileges granted"

ping -c1 -W3 8.8.8.8 &>/dev/null || fail "No internet connection"
ok "Internet connection available"

# Install directory
section "Install directory"

if [[ -n "${GNS3_DIR:-}" ]]; then
    ok "GNS3_DIR exported, using it"
elif [[ ! -f "$MARKER" ]]; then
    touch "$MARKER"
    printf "\n  ${YELLOW}${BOLD}First run: GNS3_DIR is not set${R}\n\n"
    printf "  ${GRAY}To choose where GNS3 is installed, export the variable and run again:${R}\n\n"
    printf "    ${ORANGE}export GNS3_DIR=/path/you/want${R}\n"
    printf "    ${ORANGE}bash %s${R}\n\n" "$0"
    printf "  ${GRAY}If you run the script again without exporting it,${R}\n"
    printf "  ${GRAY}GNS3 will be installed in${R} ${ORANGE}%s${R}\n\n" "$HOME/GNS3"
    printf "${CYAN}${LINE_DOUBLE}${R}\n\n"
    exit 0
else
    GNS3_DIR="$HOME/GNS3"
    info "GNS3_DIR not exported, using default"
fi

GNS3_DIR="${GNS3_DIR/#\~/$HOME}"      # expand a literal leading ~
mkdir -p "$GNS3_DIR" || fail "Could not create $GNS3_DIR"
GNS3_DIR="$(cd "$GNS3_DIR" && pwd)"
SRC_DIR="$GNS3_DIR/src"
VENV_DIR="$GNS3_DIR/.venv"
mkdir -p "$SRC_DIR"
printf "  ${GREEN}[OK]${R} Install directory: ${ORANGE}%s${R}\n" "$GNS3_DIR"

# Update the system
section "Updating the system"

export DEBIAN_FRONTEND=noninteractive

spinner "apt update - refreshing package lists"       sudo apt-get update -qq
spinner "apt upgrade - upgrading packages"            sudo apt-get upgrade -yq

# Install dependencies
section "Installing dependencies"

# Let non-root users capture packets with Wireshark (avoids the debconf prompt)
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections

PACKAGES=(
    python3
    python3-full
    python3-venv
    python3-pip
    python3-pyqt6
    python3-pyqt6.qtwebsockets
    python3-pyqt6.qtsvg
    qemu-system-x86
    qemu-utils
    libvirt-daemon-system
    libvirt-clients
    virtinst
    git
    make
    cmake
    build-essential
    libelf-dev
    libpcap-dev
    libpcap0.8-dev
    libcap2-bin
    cpu-checker
    wireshark
    # Qt xcb platform plugin dependencies (needed by the PyQt6 GUI)
    libxcb-cursor0
    libxkbcommon-x11-0
    libxcb-icccm4
    libxcb-image0
    libxcb-keysyms1
    libxcb-render-util0
    libxcb-shape0
    libxcb-xinerama0
    libxcb-xkb1
    libegl1
    libgl1
)
for pkg in "${PACKAGES[@]}"; do
    spinner "Installing ${pkg}" sudo apt-get install -yq "$pkg"
done

# Python venv and GNS3
section "Installing GNS3 in a virtual environment"

if [[ ! -d "$VENV_DIR" ]]; then
    spinner "Creating venv in ${VENV_DIR}" python3 -m venv "$VENV_DIR"
else
    ok "venv already exists: ${VENV_DIR}"
fi

spinner "pip - upgrading pip, setuptools, wheel"  pip_install pip install --upgrade pip setuptools wheel
spinner "pip - installing gns3-server, gns3-gui, PyQt6" pip_install pip install gns3-server gns3-gui PyQt6

# Build GNS3 helper tools
section "Building ubridge, dynamips and vpcs"

spinner "ubridge - clone, build and install"   build_ubridge
spinner "dynamips - clone, build and install"  build_dynamips
spinner "vpcs - clone, build and install"      build_vpcs

# Groups and services
section "Configuring groups and libvirt"

GROUPS_TO_ADD=()
for grp in kvm libvirt wireshark; do
    if getent group "$grp" &>/dev/null; then
        GROUPS_TO_ADD+=("$grp")
    else
        info "Group '$grp' does not exist, skipping"
    fi
done
if [[ ${#GROUPS_TO_ADD[@]} -gt 0 ]]; then
    GROUPS_CSV=$(IFS=,; echo "${GROUPS_TO_ADD[*]}")
    sudo usermod -aG "$GROUPS_CSV" "$USER"
    printf "  ${GREEN}[OK]${R} ${ORANGE}%s${R} added to: ${ORANGE}%s${R}\n" "$USER" "$GROUPS_CSV"
fi

sudo systemctl enable --now libvirtd
sudo systemctl is-active --quiet libvirtd || fail "libvirtd service is not running"
ok "libvirtd is enabled and running"

if [[ -e /dev/kvm ]]; then
    ok "/dev/kvm is present"
else
    info "/dev/kvm not found (enable virtualization / nested virtualization in the VM or BIOS)"
fi
if sudo kvm-ok &>/dev/null; then
    ok "KVM acceleration can be used"
else
    info "kvm-ok reports KVM acceleration is not available"
fi

# Verification
section "Verifying installation"

# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

check_cmd() {
    local name="$1" path
    if path=$(command -v "$name" 2>/dev/null); then
        printf "  ${GREEN}[OK]${R} %-12s ${GRAY}%s${R}\n" "$name" "$path"
    else
        printf "  ${RED}[MISSING]${R} %s\n" "$name"
    fi
}
for cmd in gns3 gns3server ubridge dynamips vpcs; do
    check_cmd "$cmd"
done

# Graphical environment check (the GNS3 GUI aborts without it)
section "Checking graphical environment"

if [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
    ok "Graphical session detected (${XDG_SESSION_TYPE:-unknown})"
else
    info "No graphical session detected (DISPLAY and WAYLAND_DISPLAY are empty)"
    info "'gns3' (GUI) will abort here. Options:"
    printf "    ${GRAY}- Run it from a desktop session or the VM graphical console${R}\n"
    printf "    ${GRAY}- Connect with ${ORANGE}ssh -X${GRAY} and run gns3 (slow)${R}\n"
    printf "    ${GRAY}- Use this machine only as server: ${ORANGE}gns3server${GRAY},${R}\n"
    printf "    ${GRAY}  and open the GUI from another PC pointing to this server${R}\n"
fi

# Summary
printf "\n${CYAN}${LINE_DOUBLE}${R}\n"
printf "\n  ${GREEN}${BOLD}Setup completed${R}\n\n"
printf "  ${GRAY}Install directory${R}      ${ORANGE}%s${R}\n" "$GNS3_DIR"
printf "  ${GRAY}Virtual environment${R}    ${ORANGE}%s${R}\n" "$VENV_DIR"
printf "  ${GRAY}Sources${R}                ${ORANGE}%s${R}\n" "$SRC_DIR"
printf "  ${GRAY}User${R}                   ${ORANGE}%s${R}\n" "$USER"
printf "  ${GRAY}Finished${R}               ${GRAY}%s${R}\n" "$(date '+%Y-%m-%d %H:%M:%S')"
printf "  ${GRAY}Hostname${R}               ${GRAY}%s${R}\n" "$(hostname)"
printf "\n  ${YELLOW}Log out and back in${R} ${GRAY}so the new groups (kvm, libvirt, wireshark) apply.${R}\n"
printf "\n  ${GRAY}To start GNS3:${R}\n"
printf "    ${ORANGE}source %s/bin/activate${R}\n" "$VENV_DIR"
printf "    ${ORANGE}gns3${R}            ${GRAY}# GUI${R}\n"
printf "    ${ORANGE}gns3server${R}      ${GRAY}# server only${R}\n"
printf "\n${CYAN}${LINE_DOUBLE}${R}\n\n"
