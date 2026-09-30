#!/usr/bin/env bash
set -euo pipefail

LOGFILE="/var/log/update-discord.log"
TMP_DEB="/tmp/discord.deb"
URL="https://discord.com/api/download?platform=linux&format=deb"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}

log "Checking installed version..."
INSTALLED_VERSION=$(dpkg -s discord 2>/dev/null | grep '^Version:' | awk '{print $2}' || echo "none")

log "Downloading the latest available version..."
curl -sL -o "$TMP_DEB" "$URL"

# Extract the version from the downloaded package before installing it
NEW_VERSION=$(dpkg-deb -f "$TMP_DEB" Version)

if [ "$INSTALLED_VERSION" == "$NEW_VERSION" ]; then
    log "Discord is already up to date (version $INSTALLED_VERSION). Nothing to do."
    rm -f "$TMP_DEB"
    exit 0
fi

log "New version detected: $NEW_VERSION (current: $INSTALLED_VERSION). Installing..."
apt-get install -y "$TMP_DEB"

rm -f "$TMP_DEB"
log "Discord updated successfully to version $NEW_VERSION."
