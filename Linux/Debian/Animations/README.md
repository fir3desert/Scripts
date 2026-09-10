# Terminal animations

These scripts are small, standalone previews of terminal animations that can
be used while a command is running. They do not change the system.

## Available animations

| File | Animation | Best use |
| --- | --- | --- |
| `spinner.sh` | `-`, `\`, `\|`, `/` | Unknown-duration commands |
| `ellipsis.sh` | `.`, `..`, `...` | Simple status messages |
| `loading.sh` | `Loading`, `Loading.`, `Loading..`, `Loading...` | Unknown-duration commands |
| `progress-bar.sh` | `0%` to `100%` | Commands with a known number of steps |
| `pulse.sh` | Expanding and contracting bar | Indeterminate work status |

Run any preview from the repository root:

```bash
bash Linux/Debian/Animations/spinner.sh
bash Linux/Debian/Animations/ellipsis.sh
bash Linux/Debian/Animations/loading.sh
bash Linux/Debian/Animations/progress-bar.sh
bash Linux/Debian/Animations/pulse.sh
```

Examples that execute real system commands are kept in the `Examples/`
subdirectory. Each animation has its own `apt-get install` example. Every
example installs `vim`, `curl`, and `git`; review them before running them.

```bash
sudo bash Linux/Debian/Animations/Examples/apt-install-spinner.sh
sudo bash Linux/Debian/Animations/Examples/apt-install-ellipsis.sh
sudo bash Linux/Debian/Animations/Examples/apt-install-loading.sh
sudo bash Linux/Debian/Animations/Examples/apt-install-pulse.sh
sudo bash Linux/Debian/Animations/Examples/apt-install-progress-bar.sh
```

## Included apt examples

The `Examples/` directory contains one complete, independent `apt-get install`
script for each animation. Every script installs `vim`, `curl`, and `git`:

Each example writes the output of the active `apt-get` command to its own
temporary log file. If a package installation fails, the script stops and
points to that log:

| Example | Animation | Log |
| --- | --- | --- |
| `apt-install-spinner.sh` | Spinner | `/tmp/apt-install-spinner.log` |
| `apt-install-ellipsis.sh` | Ellipsis | `/tmp/apt-install-ellipsis.log` |
| `apt-install-loading.sh` | Loading | `/tmp/apt-install-loading.log` |
| `apt-install-pulse.sh` | Pulse | `/tmp/apt-install-pulse.log` |
| `apt-install-progress-bar.sh` | Progress bar | `/tmp/apt-install-progress-bar.log` |

Run the desired example from the repository root:

```bash
sudo bash Linux/Debian/Animations/Examples/apt-install-spinner.sh
sudo bash Linux/Debian/Animations/Examples/apt-install-ellipsis.sh
sudo bash Linux/Debian/Animations/Examples/apt-install-loading.sh
sudo bash Linux/Debian/Animations/Examples/apt-install-pulse.sh
sudo bash Linux/Debian/Animations/Examples/apt-install-progress-bar.sh
```

The progress-bar example uses the number of completed packages as its known
steps. Its percentage does not represent the internal progress of `apt`.

## Important notes

- Use `apt-get` in scripts instead of interactive `apt`.
- Keep `-y` for non-interactive installation.
- Use `wait "$pid"`; `kill -0` only tells you whether the process still exists.
- Do not hide errors. Keep the command output in a temporary log and return a
  non-zero status when the command fails.
- An indeterminate animation cannot represent real installation progress.
  Use `progress-bar.sh` only for work where the total number of steps is known.
- Preview files execute simulated commands only. Copy the function into your
  own script rather than sourcing a preview file, because previews run code
  immediately when executed.
- Every script in `Examples/` executes real installations and requires root
  privileges.
