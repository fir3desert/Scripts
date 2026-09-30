# Discord update helper

This folder contains a simple helper to keep Discord updated automatically on Debian-based systems.

The script downloads the latest Debian package from Discord's official website, compares it with the version already installed, and upgrades it if needed.

## Important

Before using it, you must update the paths to match your system.

In particular, check the service file:

```ini
[Service]
Type=oneshot
ExecStart=/path/to/discord-update.sh
```

Replace `/path/to/discord-update.sh` with the actual path where this repository is stored on your machine, for example:

```ini
ExecStart=/home/your-user/Scripts/Linux/Debian/Discord/discord-update.sh
```

The same applies to any custom automation you set up. If you move the repo or run it from another user account, update the path before enabling the timer.

## How to install and run it

From the repository root, or from inside this folder, you can copy the service and timer to `/etc/systemd/system` and enable them:

```bash
sudo cp discord-update.service /etc/systemd/system/
sudo cp discord-update.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now discord-update.timer
```

If you prefer a cron-based approach instead of systemd, you can add a daily entry:

```bash
crontab -e
```

Then add:

```cron
0 3 * * * /bin/bash /home/your-user/Scripts/Linux/Debian/Discord/discord-update.sh >> /var/log/update-discord.log 2>&1
```

Replace the path with your real location.

## Notes

- The script writes logs to `/var/log/update-discord.log`.
- It uses the official Discord Debian package.
- It is intended for personal automation and should be checked before running on a system you do not control.
- If you change the repository path, re-run the service install or update the cron entry.
