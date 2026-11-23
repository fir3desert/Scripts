# MikroTik

RouterOS automation scripts for MikroTik devices.

## Available automation

| Folder | Description |
| --- | --- |
| [auto-updater](auto-updater/README.md) | Checks the Stable channel once a day, sends a Discord notification when an update is available, installs it, and reboots the router. |

The auto-updater folder contains:

- `README.md` — full installation and configuration guide
- `auto-update.rsc` — RouterOS script source with a Discord webhook placeholder
- `scheduler.md` — command to schedule the script daily

## Before using it

- The scripts target RouterOS 7 and require internet access from the router.
- Replace every webhook placeholder with your own private Discord webhook URL.
- Automatic updates cause a temporary loss of connectivity and a reboot; take a configuration backup first.
