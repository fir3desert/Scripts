# OpenCode

This folder is dedicated to scripts and workflows I use to test ideas, automate small tasks, and experiment with local tools and work routines.

The main idea is to keep lightweight utilities and quick automation helpers handy, especially for tasks where I want to trigger something from the terminal and then get a quick notification when the workflow finishes.

## What you'll find here

| File | Description |
| --- | --- |
| `workflow.sh` | Posts a short message to a Discord webhook when a task is finished. Requires `curl`. |

## Workflow usage

`workflow.sh` takes the completion message as its first argument. From the repository root:

```bash
bash OpenCode/workflow.sh "Finished the task: reviewed the project, updated the docs, and validated the shell scripts."
```

If no message is given, it sends `./workflow.sh finished successfully`.

Before using it, replace the placeholder webhook URL in [`workflow.sh`](workflow.sh) with your own Discord webhook:

```bash
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/REPLACE_WITH_YOUR_WEBHOOK_ID/REPLACE_WITH_YOUR_TOKEN"
```

Keep the webhook private: anyone who has it can post to that Discord channel.

This folder is meant to be used as a lightweight handoff for OpenCode: once the AI finishes a task, tell it to run `workflow.sh` with a short summary of what it completed. Example prompt instruction:

```text
When you're done, run bash OpenCode/workflow.sh "Finished the task: reviewed the project, updated the docs, and validated the shell scripts."
```

The idea is simple: finish the task, then send a quick summary so the notification tells me what happened without needing a long log.

## Important

- The script is not executable in the repository, so invoke it with `bash` or add the executable bit yourself.
- Anything here may be incomplete, temporary, or tailored to my personal use.
- Always review commands and requirements before running anything.
- The main goal is to keep work practical, lightweight, and easy to trigger from the prompt.
