
/system script add name=auto-update policy=ftp,read,write,policy,reboot,test source={
    :local webhook "https://Webhook....."

    /system package update set channel=stable

    :local update [/system package update check-for-updates as-value]

    :local installed ($update->"installed-version")
    :local latest ($update->"latest-version")

    :log info ("Installed version: " . $installed)
    :log info ("Latest version: " . $latest)

    :if ($installed != $latest) do={

        :local message ("MikroTik: Update available! Installed: " . $installed . " | Latest: " . $latest . ". Installing and rebooting.")

        :local payload ("{\"content\":\"" . $message . "\"}")

        /tool fetch url=$webhook http-method=post \
            http-header-field="Content-Type: application/json" \
            http-data=$payload output=none

        :delay 5s

        /system package update install
    } else={
        :log info "MikroTik is already up to date"
    }
}
