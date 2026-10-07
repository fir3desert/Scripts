# Personal scripts

This repository is a small personal toolbox of shell scripts for Linux system setup, automation experiments, and quick utilities. The goal is to keep simple helpers for day-to-day tasks, learning, and local experimentation without turning them into a formal project.

These scripts are not meant to be universal or production-grade by default. Most are tailored to a specific machine or Debian-based environment and should be reviewed before execution.

## What is in this repository

- Debian 13 setup scripts for a new server or VM
- Docker installation helper for Debian 13
- Hardware inspection script for IOMMU groups
- Terminal animation previews and apt-install examples
- Discord update automation with systemd timer/service files
- KDE Plasma restart helper
- OpenCode workflow helper for quick Discord notifications
- Telegram bot utility to inspect chat IDs from recent updates

## Repository structure

```text
.
├── Linux/
│   ├── Debian/
│   │   ├── debian13-setup.sh
│   │   ├── install-docker-debian13.sh
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
│   │   └── Kde/
│   │       └── plasma-restart.sh
│   └── Hardware/
│       └── iommu-groups.sh
├── OpenCode/
│   ├── README.md
│   └── workflow.sh
├── Telegram/
│   ├── README.md
│   └── telegram_get_chat_id.sh
├── README.md
└── .git/
```

## Main scripts

### Linux/Debian/debian13-setup.sh
This script performs a basic Debian 13 server setup: updates the system, installs common administration tools, enables SSH, and adds the primary user to the sudo group.

```bash
sudo bash Linux/Debian/debian13-setup.sh
```

### Linux/Debian/install-docker-debian13.sh
Installs Docker Engine and the Docker Compose plugin using the official Docker APT repository for Debian 13.

```bash
sudo bash Linux/Debian/install-docker-debian13.sh
```

### Linux/Hardware/iommu-groups.sh
Lists all IOMMU groups and the PCI devices associated with them. Useful when preparing GPU or hardware passthrough setups.

```bash
bash Linux/Hardware/iommu-groups.sh
```

### Linux/Debian/Animations
Contains standalone terminal animation previews and real apt examples. They are useful as UI feedback while a command is running.

Examples:

```bash
bash Linux/Debian/Animations/spinner.sh
bash Linux/Debian/Animations/progress-bar.sh
sudo bash Linux/Debian/Animations/Examples/apt-install-spinner.sh
```

### Linux/Debian/Discord
Helper for downloading the latest official Discord Debian package and installing it when a newer version is available.

It includes:

- `discord-update.sh`: checks the installed version and upgrades it if needed
- `discord-update.service`: systemd one-shot service
- `discord-update.timer`: scheduled daily run

Update the path in the service file before enabling it:

```ini
[Service]
Type=oneshot
ExecStart=/path/to/discord-update.sh
```

Then install it with:

```bash
sudo cp Linux/Debian/Discord/discord-update.service /etc/systemd/system/
sudo cp Linux/Debian/Discord/discord-update.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now discord-update.timer
```

### Linux/Debian/Kde/plasma-restart.sh
Restarts the Plasma shell in the current KDE session.

```bash
bash Linux/Debian/Kde/plasma-restart.sh
```

### OpenCode/workflow.sh
A lightweight Discord webhook utility used to post a completion message after a task is finished.

```bash
./OpenCode/workflow.sh "Finished the task and validated the changes."
```

Before using it, replace the placeholder webhook URL in the file with your own Discord webhook.

### Telegram/telegram_get_chat_id.sh
Queries the Telegram Bot API to list recent chat IDs the bot has seen.

```bash
./Telegram/telegram_get_chat_id.sh <BOT_TOKEN>
```

Or:

```bash
export TELEGRAM_BOT_TOKEN="123456:ABC..."
./Telegram/telegram_get_chat_id.sh
```

## Recommended usage

These scripts are meant to be inspected before running. Some require root privileges, internet access, or a very specific Linux environment.

```bash
sudo bash Linux/Debian/debian13-setup.sh
sudo bash Linux/Debian/install-docker-debian13.sh
bash Linux/Hardware/iommu-groups.sh
```

## Important notes

- Review every script before executing it.
- Some commands are designed for Debian 13 and may assume a specific user, service, or package setup.
- Scripts are intentionally simple and personal; they are not a complete production solution.
- Never expose or commit Telegram bot tokens or other secrets to a public repository.
- The Discord updater writes to `/var/log/update-discord.log` and should be checked before use on a system you do not control.
