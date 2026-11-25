
/system script add name=auto-update policy=ftp,read,write,policy,reboot,test source={
    :delay 1m

    /system package update set channel=stable
    /system package update check-for-updates once
    :delay 15s

    :local installed [/system package update get installed-version]
    :local latest [/system package update get latest-version]
    :local router [/system identity get name]
    :local webhook "https://discord.com/api/webhooks/"

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
