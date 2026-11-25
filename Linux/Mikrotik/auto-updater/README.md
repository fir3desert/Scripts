# MikroTik RouterOS Auto Updater

Automatically check for RouterOS updates and install new stable releases, with Discord notifications before the router reboots.

The ready-to-import script is in [`auto-update.rsc`](auto-update.rsc) and the scheduler command is also saved in [`scheduler.md`](scheduler.md).

## Features

- Automatic RouterOS update checks.
- Uses the **Stable** update channel.
- Discord webhook notification when an update is available.
- Automatically downloads and installs new versions.
- Router reboot after installation (triggered by RouterOS package installation).
- Scheduled daily execution.
- Lightweight script with no external dependencies.

## Requirements

- MikroTik router running RouterOS 7.
- Internet connectivity (including DNS and HTTPS access to Discord).
- Discord webhook URL.
- Permission to manage scripts, packages, and scheduler tasks.

## Installation

### 1. Configure the Discord webhook

Create a webhook in your Discord server:

1. Open your Discord channel settings.
2. Go to **Integrations → Webhooks**.
3. Create a new webhook.
4. Copy the webhook URL.

Keep this URL private. Anyone with access to it can send messages to your Discord channel.

### 2. Create the update script

Upload [`auto-update.rsc`](auto-update.rsc) to the router's file system and import it, replacing `YOUR_DISCORD_WEBHOOK` in the file first:

```routeros
/import file=auto-update.rsc
```

Or paste the equivalent command directly in the MikroTik Terminal, replacing `YOUR_DISCORD_WEBHOOK` with your webhook URL:

```routeros

/system script add name=auto-update-discord policy=ftp,read,write,policy,reboot,test source={
    :delay 1m

    /system package update set channel=stable
    /system package update check-for-updates once
    :delay 15s

    :local installed [/system package update get installed-version]
    :local latest [/system package update get latest-version]
    :local router [/system identity get name]
    :local webhook "https://discord.com/api/webhooks/..."

    :if ($installed != $latest) do={

        :local payload ("{\"embeds\":[{\"title\":\"RouterOS Update\",\"color\":15105570,\"fields\":[{\"name\":\"Router\",\"value\":\"" . $router . "\",\"inline\":true},{\"name\":\"Old version\",\"value\":\"" . $installed . "\",\"inline\":true},{\"name\":\"New version\",\"value\":\"" . $latest . "\",\"inline\":true}],\"footer\":{\"text\":\"Installing update and rebooting\"}}]}")

        /tool fetch url=$webhook http-method=post http-header-field="Content-Type: application/json" http-data=$payload keep-result=no

        :log warning ("Updating RouterOS from " . $installed . " to " . $latest)

        :delay 5s
        /system package update install
    } else={
        :log info ("RouterOS is up to date: " . $installed)
    }
}
```

The script stores the webhook in the global variable `DC_Webhook`, so it is visible in plain text to users who can read RouterOS scripts.

### 3. Configure the scheduler

Create a scheduler task to check for updates every day at 03:00 AM:

```routeros
/system scheduler add name=auto-update start-time=03:00:00 interval=1d on-event="/system script run auto-update"
```

Verify it with:

```routeros
/system scheduler print where name=auto-update
```

### 4. Test the script

Run the script manually:

```routeros
/system script run auto-update
```

Review recent RouterOS log entries while it runs:

```routeros
/log print
```

Package update and reboot events are logged by RouterOS itself. This script does not add a custom `AUTOUPDATE` log tag, so filtering for that text will not show its activity.

## Discord notifications

When a new RouterOS version is detected, the router sends this notification:

> MikroTik: Update available! Installing and rebooting now.

No notification is sent when the router is already up to date. A failed `fetch` is not retried separately by this script.

## Configuration

| Setting | Value |
| --- | --- |
| Script name | `auto-update` |
| Scheduler name | `auto-update` |
| Update channel | `stable` |
| Check interval | Every 24 hours |
| Scheduled time | 03:00 AM |
| Notifications | Discord Webhook |

## Important notes

- The router will temporarily lose connectivity during the update and reboot.
- `/system/package/update/install` triggers the reboot; no separate reboot command is needed.
- Only the Stable update channel is used.
- Make sure your router has a working internet connection.
- Keep your Discord webhook URL private.
- Consider maintaining a separate configuration backup before enabling automatic updates.
- The script currently updates RouterOS packages. RouterBOARD firmware is not automatically upgraded.
