# SSH-Melody

Play a short melody through the internal PC speaker whenever you log in to a Linux server via SSH.

Designed for Debian-based systems, including Proxmox VE, using the `beep` utility and a compatible PC speaker.

## Features

- Plays a melody on interactive SSH logins.
- Uses the internal PC speaker instead of an external audio device.
- Lightweight Bash script with no background services.
- Customizable notes, frequencies, and durations.
- Works locally for testing and through SSH once configured.

## Requirements

- Debian or a Debian-based Linux distribution.
- Root access, or sufficient permissions to use the PC speaker.
- The `beep` package.
- Compatible PC speaker hardware and kernel support.

**Note:** Not all servers have a compatible internal speaker. Modern systems may restrict access to the PC speaker, so functionality depends on the hardware and kernel configuration.

## Installation

### 1. Install the dependencies

Update the package list and install `beep`:

```bash
apt update
apt install beep
```

### 2. Create the melody script

Create the script at `/usr/local/bin/ssh-melody`:

```bash
vim /usr/local/bin/ssh-melody
```

Add the following content:

```bash
#!/bin/bash

beep -f 784 -l 130
beep -f 988 -l 130
beep -f 1175 -l 180
beep -f 988 -l 130
beep -f 1175 -l 130
beep -f 1568 -l 300
```

Save and close the file.

Make it executable:

```bash
chmod +x /usr/local/bin/ssh-melody
```

### 3. Test the melody

Run the script manually:

```bash
/usr/local/bin/ssh-melody
```

If the melody plays correctly, continue with the SSH login configuration.

If it does not work, verify that the PC speaker is supported and that the `pcspkr` kernel module is available:

```bash
lsmod | grep pcspkr
```

### 4. Configure automatic playback on SSH login

Edit the root user's Bash configuration:

```bash
vim /root/.bashrc
```

Add the following lines at the end of the file:

```bash
# Play a melody on interactive SSH login
if [[ -n "$SSH_CONNECTION" && $- == *i* ]]; then
    /usr/local/bin/ssh-melody
fi
```

Save and close the file.

This checks that the session is interactive and that an SSH connection is present before playing the melody.

**Important:** This configuration applies to the root user's Bash sessions. Other users need the configuration in their own Bash startup file. Depending on the SSH client and server configuration, non-interactive commands and other shells may behave differently.

### 5. Verify the configuration

Open a new SSH session:

```bash
ssh root@SERVER_IP
```

Replace `SERVER_IP` with your server's IP address.

The melody should play when the interactive SSH session starts.

Keep your existing session open until you have verified that the new configuration works.

## Customization

Each `beep` command defines a note:

```bash
beep -f 784 -l 130
```

- `-f`: frequency in hertz (Hz). Higher values produce higher-pitched tones.
- `-l`: duration in milliseconds.

Change the frequencies and durations to create your own melody.

For more information:

```bash
man beep
```

## Uninstallation

Remove the SSH login configuration from `/root/.bashrc`:

```bash
vim /root/.bashrc
```

Delete the `# Play a melody on interactive SSH login` block.

Then remove the script:

```bash
rm /usr/local/bin/ssh-melody
```

Optionally, remove the package if it is no longer needed:

```bash
apt remove beep
```

## Tested Environment

- Proxmox VE (Debian-based)
- Bash
- `beep`
- Compatible internal PC speaker

Hardware and kernel compatibility may vary between systems.

## License

This project is released under the MIT License, unless otherwise specified by the repository owner.
