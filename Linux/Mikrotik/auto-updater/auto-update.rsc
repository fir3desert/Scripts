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
