# MikroTik RouterOS Auto Updater

Automatically check for RouterOS updates and install new stable releases, with Discord notifications before the router reboots.

## Features

- Automatic RouterOS update checks.
- Uses the **Stable** update channel.
- Discord webhook notifications when an update is available.
- Automatically downloads and installs new versions.
- Automatic router reboot after installation.
- Scheduled daily execution.
- Lightweight script with no external dependencies.

## Requirements

- MikroTik router running RouterOS 7.
- Internet connectivity.
- Discord webhook URL.
- Permission to manage scripts, packages and scheduler tasks.

## Installation

### 1. Configure the Discord webhook

Create a webhook in your Discord server:

1. Open your Discord channel settings.
2. Go to **Integrations → Webhooks**.
3. Create a new webhook.
4. Copy the webhook URL.

Keep this URL private. Anyone with access to it can send messages to your Discord channel.

### 2. Create the update script

Open MikroTik Terminal and execute the following command.

Replace `YOUR_DISCORD_WEBHOOK` with your webhook URL.

```routeros
/system script add name=auto-update policy=read,write,policy,reboot,test source={
    :global DC_Webhook
    :set DC_Webhook "YOUR_DISCORD_WEBHOOK"

    /system/package/update/set channel=stable
    /system/package/update/check-for-updates once
    :delay 15s

    :if ([/system/package/update get status] = "New version is available") do={

        /tool fetch url=$DC_Webhook http-method=post http-header-field="Content-Type: application/json" http-data="{\"content\":\"MikroTik: Update available! Installing and rebooting now.\"}" keep-result=no

        :delay 5s
        /system/package/update/install
    }
}
```

### 3. Configure the scheduler

Create a scheduler task to check for updates every day at 03:00 AM.

```routeros
/system scheduler add name=auto-update start-time=03:00:00 interval=1d on-event="/system script run auto-update"
```

### 4. Test the script

Run the script manually:

```routeros
/system script run auto-update
```

Check the logs:

```routeros
/log print where message~"AUTOUPDATE"
```

## Discord Notifications

When a new RouterOS version is detected, the router sends this notification:

> MikroTik: Update available! Installing and rebooting now.

No notification is sent when the router is already up to date.

## Configuration

| Setting | Value |
|---|---|
| Script name | `auto-update` |
| Scheduler name | `auto-update` |
| Update channel | `stable` |
| Check interval | Every 24 hours |
| Scheduled time | 03:00 AM |
| Notifications | Discord Webhook |

## Important Notes

- The router will temporarily lose connectivity during the update and reboot.
- Only the Stable update channel is used.
- Make sure your router has a working internet connection.
- Keep your Discord webhook URL private.
- Consider maintaining a separate configuration backup before enabling automatic updates.
- The script currently updates RouterOS packages. RouterBOARD firmware is not automatically upgraded.
