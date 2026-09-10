# Homelab Scripts

Personal collection of scripts for automating common tasks in my homelab. This
repository will grow as I add scripts for preparing, administering, and
maintaining my servers and services.

> **Notice:** these scripts are designed for my environment and may assume a
> specific configuration. Review and adapt them before running them on another
> system. Do not run them in production without checking every command and its
> effects first.

## Structure

```text
.
├── Linux/
│   └── Debian/
│       ├── debian13-setup.sh
│       └── Animations/
│           ├── ellipsis.sh
│           ├── loading.sh
│           ├── README.md
│           ├── pulse.sh
│           ├── progress-bar.sh
│           ├── spinner.sh
│           └── Examples/
│               ├── apt-install-ellipsis.sh
│               ├── apt-install-loading.sh
│               ├── apt-install-progress-bar.sh
│               ├── apt-install-pulse.sh
│               └── apt-install-spinner.sh
├── .gitattributes
├── .gitignore
└── README.md
```

## Available scripts

### `Linux/Debian/debian13-setup.sh`

Quick setup script for a new Debian 13 VM. It performs the following tasks:

- Checks that it is running as `root`.
- Checks for an Internet connection.
- Finds the user with UID `1000`.
- Updates the system with `apt`.
- Installs basic administration tools:
  - `openssh-server`
  - `sudo`
  - `curl`
  - `wget`
  - `vim`
  - `tmux`
  - `htop`
  - `btop`
  - `unzip`
  - `fzf`
- Enables and starts the SSH service.
- Adds the user with UID `1000` to the `sudo` group.
- Adds a sudoers rule for that user.
- Displays a summary of the operations performed.

### `Linux/Debian/Animations/`

Standalone previews of terminal animations for shell scripts:

- `spinner.sh` — `-`, `\`, `|`, `/`.
- `ellipsis.sh` — `.`, `..`, `...`.
- `loading.sh` — `Loading`, `Loading.`, `Loading..`, `Loading...`.
- `progress-bar.sh` — progress from `0%` to `100%`.
- `pulse.sh` — expanding and contracting bar.

Run a preview from the repository root:

```bash
bash Linux/Debian/Animations/spinner.sh
bash Linux/Debian/Animations/ellipsis.sh
bash Linux/Debian/Animations/loading.sh
bash Linux/Debian/Animations/progress-bar.sh
bash Linux/Debian/Animations/pulse.sh
```

Each animation also has an independent `apt-get install` example in
[`Linux/Debian/Animations/Examples/`](Linux/Debian/Animations/Examples/).
The examples install `vim`, `curl`, and `git` and require `root` or `sudo`:

| Example | Animation |
| --- | --- |
| [`apt-install-spinner.sh`](Linux/Debian/Animations/Examples/apt-install-spinner.sh) | Spinner |
| [`apt-install-ellipsis.sh`](Linux/Debian/Animations/Examples/apt-install-ellipsis.sh) | Ellipsis |
| [`apt-install-loading.sh`](Linux/Debian/Animations/Examples/apt-install-loading.sh) | Loading |
| [`apt-install-pulse.sh`](Linux/Debian/Animations/Examples/apt-install-pulse.sh) | Pulse |
| [`apt-install-progress-bar.sh`](Linux/Debian/Animations/Examples/apt-install-progress-bar.sh) | Progress bar |

For usage details, log locations, and implementation notes, see
[`Linux/Debian/Animations/README.md`](Linux/Debian/Animations/README.md).

## Requirements

- A **Debian 13** installation or VM.
- Access as `root` or permission to use `sudo`.
- An Internet connection.
- A local user with UID `1000`.
- A working `systemd` installation to manage the SSH service.

## Usage

Clone the repository on the Debian machine and run the script with administrator
privileges:

```bash
git clone <REPO_URL>
cd Scripts
sudo bash Linux/Debian/debian13-setup.sh
```

It can also be run directly as `root`:

```bash
bash Linux/Debian/debian13-setup.sh
```

The script uses `set -euo pipefail`: if a check or operation fails, execution
stops. The output of the last command run through the progress indicator is
temporarily saved to `/tmp/setup_last_output` to help with troubleshooting.

## After running the script

If the user already had an open session, they must log out and log back in for
the `sudo` group change to take effect. Remote access and group membership can
then be checked with:

```bash
ssh User@SERVER_IP
groups
sudo -v
```

Replace `User` and `SERVER_IP` with the values for your environment.

## Security and maintenance

- Always review the changes before running a script with administrator
  privileges.
- The script enables SSH, but does not configure keys, `sshd_config`, a
  firewall, or hardening policies.
- The added sudo rule allows the user to run commands with `sudo` by entering
  their password.
- Do not store credentials, private keys, or sensitive configuration in this
  repository.
- The scripts may be tailored to my homelab and are not intended to be a
  universal hardening or deployment solution.
- Animation previews do not change the system. The scripts under
  `Animations/Examples/` execute real package installations.

## Repository conventions

- Shell scripts are stored with `LF` line endings.
- Generated files, logs, secrets, and private keys are excluded through
  `.gitignore`.
- New scripts should include a brief description, requirements, and a usage
  example in this README.
