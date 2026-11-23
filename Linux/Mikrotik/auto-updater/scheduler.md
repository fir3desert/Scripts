# Scheduler

Run the auto-update script every day at 03:00 from the MikroTik Terminal:

```routeros
/system scheduler add name=auto-update start-time=03:00:00 interval=1d on-event="/system script run auto-update"
```

Verify the task with:

```routeros
/system scheduler print where name=auto-update
```

Create the `auto-update` script first (see [README.md](README.md)). To remove the schedule later:

```routeros
/system scheduler remove [find name=auto-update]
```
