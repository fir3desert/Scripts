# Personal scripts

This repository contains a collection of scripts I made for fun, to learn, and to automate small tasks in my environment. They are simple, practical pieces designed for personal use and experimentation with ideas that are useful in everyday work.

They are not meant to be a commercial project or a universal solution. Some are tailored to my setup, while others are small utilities, experiments, or automations that I keep as quick references.

## What's here

- Debian system setup and maintenance
- Docker installation on Debian 13
- Terminal animations for progress and status feedback in scripts
- Discord update automation helper with timer/service setup
- KDE Plasma GUI restart helper
- Personal folders for experiments and task-oriented work with OpenCode and Telegram

## Repository structure

```text
.
├── Linux/
│   └── Debian/
│       ├── debian13-setup.sh
│       ├── install-docker-debian13.sh
│       ├── README.md
│       ├── Animations/
│       │   ├── README.md
│       │   ├── spinner.sh
│       │   ├── ellipsis.sh
│       │   ├── loading.sh
│       │   ├── progress-bar.sh
│       │   ├── pulse.sh
│       │   └── Examples/
│       │       ├── apt-install-spinner.sh
│       │       ├── apt-install-ellipsis.sh
│       │       ├── apt-install-loading.sh
│       │       ├── apt-install-pulse.sh
│       │       └── apt-install-progress-bar.sh
│       ├── Discord/
│       │   ├── README.md
│       │   ├── discord-update.sh
│       │   ├── discord-update.service
│       │   ├── discord-update.timer
│       │   └── install.sh
│       └── Kde/
│           └── plasma-restart.sh
├── OpenCode/
│   ├── README.md
│   └── workflow.sh
├── Telegram/
│   ├── README.md
│   └── telegram_get_chat_id.sh
├── README.md
└── LICENSE (if added in the future)
```

## Recommended usage

These scripts are meant to be reviewed before running them. Some require administrator privileges, internet access, or a specific system configuration.

```bash
# example usage
sudo bash Linux/Debian/debian13-setup.sh
sudo bash Linux/Debian/install-docker-debian13.sh
```

## Important notes

- Review each command before running it.
- Some scripts are designed for Debian 13 and may depend on specific packages, users, or services.
- I do not treat them as definitive production solutions without checking everything first.
- The main goal is to practice, automate, and solve small tasks quickly.

## Special folders

### Linux/Debian
Scripts for preparing the system and installing core software on Debian.

### Linux/Debian/Animations
Small terminal animation examples useful for giving visual feedback while a task is running.

### Linux/Debian/Discord
Helper scripts for checking and installing the latest Discord package automatically, with a systemd timer and service setup.

### Linux/Debian/Kde
Small utilities to restart the KDE Plasma graphical session when needed.

### OpenCode
A space for personal experiments, workflow notes, and small automation ideas I test for curiosity or practical use. This folder can change over time as scripts or notes are added or removed.

### Telegram
A folder for Telegram-related scripts and utilities I created for specific tasks or experiments, including chat ID lookup helpers.

## Final note

This repo is basically a personal toolbox: scripts I created for fun, for practical tasks, and to learn more about shell automation and Linux environments. If someone uses them, they should review and adapt them to their own use case before running anything.
