# Discord update helper

This folder contains a simple helper to keep Discord updated automatically on Debian-based systems.

`discord-update.sh` downloads the latest Debian package from Discord's official website, compares it with the version already installed, and upgrades it if needed. It requires root privileges because it writes to `/var/log/update-discord.log` and installs packages with `apt-get`. It also needs `curl` and `dpkg-deb`.

## Important: update the paths

Before using the service, replace the placeholder with the absolute path where this repository is stored on your machine:

```ini
[Service]
Type=oneshot
ExecStart=/home/your-user/Scripts/Linux/Debian/Discord/discord-update.sh
```

Make the script executable, then copy the service and timer into systemd:

```bash
chmod +x Linux/Debian/Discord/discord-update.sh
sudo cp Linux/Debian/Discord/discord-update.service /etc/systemd/system/
sudo cp Linux/Debian/Discord/discord-update.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now discord-update.timer
```

If you move the repository or run it from another user account, update `ExecStart` and repeat these steps.

## Timer behavior and verification

`discord-update.timer` runs `OnCalendar=daily` with `Persistent=true` and a randomized delay of up to 15 minutes, so the exact start time may vary.

Check the timer and the last run with:

```bash
systemctl list-timers discord-update.timer
systemctl status discord-update.service
journalctl -u discord-update.service
tail -n 50 /var/log/update-discord.log
```

## Cron alternative

If you prefer cron, use the root crontab because the script needs root privileges:

```bash
sudo crontab -e
```

Add a daily entry, replacing the path with your real location:

```cron
0 3 * * * /bin/bash /home/your-user/Scripts/Linux/Debian/Discord/discord-update.sh >> /var/log/update-discord.log 2>&1
```

## Notes

- The script writes logs to `/var/log/update-discord.log`.
- It uses the official Discord Debian package.
- It is intended for personal automation and should be checked before running on a system you do not control.
- If the installed version and downloaded version match, the downloaded `.deb` is removed and no installation is performed.
