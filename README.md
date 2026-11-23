# Personal scripts

This repository is a small personal toolbox of shell scripts for Linux system setup, automation experiments, and quick utilities. The goal is to keep simple helpers for day-to-day tasks, learning, and local experimentation without turning them into a formal project.

These scripts are not meant to be universal or production-grade by default. Most are tailored to a specific machine or Debian-based environment and should be reviewed before execution.

## What is in this repository

- Debian 13 VM/server setup (system update, common tools, SSH, sudo for UID 1000)
- Docker Engine and Docker Compose installer for Debian 13
- GNS3 server and GUI installer for Debian 13 (Python venv, ubridge, dynamips, vpcs)
- Hardware inspection script for IOMMU groups
- Terminal animation previews and apt-install examples
- Discord update automation with systemd service and timer files
- SSH login melody using the internal PC speaker
- MikroTik RouterOS 7 auto-updater with Discord notifications
- KDE Plasma restart helper
- OpenCode workflow helper for task-completion notifications
- Telegram bot utility to inspect chat IDs from recent updates

## Repository structure

```text
.
├── Linux/
│   ├── Debian/
│   │   ├── debian13-setup.sh
│   │   ├── Animations/
│   │   │   ├── README.md
│   │   │   ├── spinner.sh
│   │   │   ├── ellipsis.sh
│   │   │   ├── loading.sh
│   │   │   ├── progress-bar.sh
│   │   │   ├── pulse.sh
│   │   │   └── Examples/
│   │   │       ├── apt-install-spinner.sh
│   │   │       ├── apt-install-ellipsis.sh
│   │   │       ├── apt-install-loading.sh
│   │   │       ├── apt-install-pulse.sh
│   │   │       └── apt-install-progress-bar.sh
│   │   ├── Discord/
│   │   │   ├── README.md
│   │   │   ├── discord-update.sh
│   │   │   ├── discord-update.service
│   │   │   └── discord-update.timer
│   │   ├── Docker/
│   │   │   └── docker-install.sh
│   │   ├── GNS3/
│   │   │   └── gns3-installer.sh
│   │   ├── Kde/
│   │   │   └── plasma-restart.sh
│   │   └── SSH-Melody/
│   │       ├── README.md
│   │       └── ssh-melody.sh
│   ├── Hardware/
│   │   └── iommu-groups.sh
│   └── Mikrotik/
│       ├── README.md
│       └── auto-updater/
│           ├── README.md
│           ├── scheduler.md
│           └── auto-update.rsc
├── OpenCode/
│   ├── README.md
│   └── workflow.sh
├── Telegram/
│   ├── README.md
│   └── telegram_get_chat_id.sh
└── README.md
```

## Main scripts

### Linux/Debian/debian13-setup.sh

Basic Debian 13 setup for a fresh VM or server. It checks internet connectivity, updates the system, installs common administration tools, enables SSH, and grants sudo access to the user with UID 1000.

```bash
sudo bash Linux/Debian/debian13-setup.sh
```

### Linux/Debian/Docker/docker-install.sh

Installs Docker Engine, the CLI, containerd, the Buildx plugin, and the Compose plugin from the official Docker APT repository for Debian 13. It also enables the Docker service and adds the invoking user (or UID 1000) to the `docker` group.

```bash
sudo bash Linux/Debian/Docker/docker-install.sh
```

Log out and back in (or run `newgrp docker`) after installation to use Docker without `sudo`.

### Linux/Debian/GNS3/gns3-installer.sh

Installs GNS3 server and GUI for Debian 13 in a Python virtual environment and builds `ubridge`, `dynamips`, and `vpcs` from source. It also installs QEMU/libvirt dependencies and adds the user to the `kvm`, `libvirt`, and `wireshark` groups when available.

Run it as a normal user with sudo privileges, not as root:

```bash
bash Linux/Debian/GNS3/gns3-installer.sh
```

On the first run it asks you to choose an install directory with `GNS3_DIR`; later runs without that variable default to `$HOME/GNS3`:

```bash
export GNS3_DIR=/path/you/want
bash Linux/Debian/GNS3/gns3-installer.sh
```

The GUI needs a graphical session. On a headless machine use `gns3server` and connect from another computer. Installation output is written to `/tmp/gns3_setup_$USER.log`.

### Linux/Hardware/iommu-groups.sh

Lists all IOMMU groups and the PCI devices associated with them. Useful when preparing GPU or hardware passthrough setups.

```bash
bash Linux/Hardware/iommu-groups.sh
```

### Linux/Debian/Animations

Contains standalone terminal animation previews and real apt examples. See the [Animations README](Linux/Debian/Animations/README.md) for the full list and log locations.

```bash
bash Linux/Debian/Animations/spinner.sh
bash Linux/Debian/Animations/progress-bar.sh
sudo bash Linux/Debian/Animations/Examples/apt-install-spinner.sh
```

### Linux/Debian/Discord

Downloads the latest official Discord Debian package and installs it when a newer version is available. See the [Discord README](Linux/Debian/Discord/README.md) for service and cron setup.

It includes:

- `discord-update.sh`: checks the installed version and upgrades it if needed
- `discord-update.service`: systemd one-shot service
- `discord-update.timer`: scheduled daily run

The script needs root privileges (it writes to `/var/log/update-discord.log` and installs packages with `apt-get`). Set an absolute path in the service file and make the script executable before enabling the timer:

```ini
[Service]
Type=oneshot
ExecStart=/home/your-user/Scripts/Linux/Debian/Discord/discord-update.sh
```

```bash
chmod +x Linux/Debian/Discord/discord-update.sh
sudo cp Linux/Debian/Discord/discord-update.service /etc/systemd/system/
sudo cp Linux/Debian/Discord/discord-update.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now discord-update.timer
```

### Linux/Debian/SSH-Melody/ssh-melody.sh

Plays a short melody through the internal PC speaker on interactive SSH logins. See the [SSH-Melody README](Linux/Debian/SSH-Melody/README.md) for the `beep` dependency and the `.bashrc` login hook.

```bash
sudo install -m 0755 Linux/Debian/SSH-Melody/ssh-melody.sh /usr/local/bin/ssh-melody
```

### Linux/Mikrotik/auto-updater

RouterOS 7 automation that checks the Stable channel daily at 03:00, sends a Discord notification when an update is available, installs it, and lets the router reboot. See the [MikroTik README](Linux/Mikrotik/README.md) and the [auto-updater README](Linux/Mikrotik/auto-updater/README.md).

Upload or paste `Linux/Mikrotik/auto-updater/auto-update.rsc` after replacing the webhook placeholder, then add the scheduler using the command in `scheduler.md`.

### Linux/Debian/Kde/plasma-restart.sh

Restarts the Plasma shell in the current KDE session.

```bash
bash Linux/Debian/Kde/plasma-restart.sh
```

### OpenCode/workflow.sh

A lightweight Discord webhook utility used to post a completion message after a task is finished. Replace the placeholder webhook URL in the script before using it.

```bash
bash OpenCode/workflow.sh "Finished the task and validated the changes."
```

### Telegram/telegram_get_chat_id.sh

Queries the Telegram Bot API to list recent chat IDs the bot has seen. Requires `curl` and `jq`.

```bash
bash Telegram/telegram_get_chat_id.sh <BOT_TOKEN>
```

Or:

```bash
export TELEGRAM_BOT_TOKEN="123456:ABC..."
bash Telegram/telegram_get_chat_id.sh
```

## Recommended usage

These scripts are meant to be inspected before running. Some require root privileges, internet access, or a very specific Linux environment.

```bash
sudo bash Linux/Debian/debian13-setup.sh
sudo bash Linux/Debian/Docker/docker-install.sh
bash Linux/Debian/GNS3/gns3-installer.sh
bash Linux/Hardware/iommu-groups.sh
```

## Important notes

- Review every script before executing it.
- Some commands are designed for Debian 13 and may assume a specific user, service, or package setup.
- `debian13-setup.sh`, the Docker installer, and the Discord updater require root; the GNS3 installer must be run as a normal user with sudo.
- Automatic updates (Discord packages and RouterOS) can change or reboot a running system. Check the respective READMEs before enabling their schedules.
- Scripts are intentionally simple and personal; they are not a complete production solution.
- Never expose or commit Discord webhook URLs, Telegram bot tokens, or other secrets to a public repository.
