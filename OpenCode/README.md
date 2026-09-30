# OpenCode

This folder is dedicated to scripts and workflows I use to test ideas, automate small tasks, and experiment with local tools and work routines.

The main idea is to keep lightweight utilities and quick automation helpers handy, especially for tasks where I want to trigger something from the terminal and then get a quick notification when the workflow finishes.

## What you'll find here

- Utilities for automating repetitive work
- Small workflow helpers for task completion notifications
- Notes and experiments for local automation ideas
- Quick prototypes for daily personal tasks

## Workflow usage

This folder is meant to be used as a lightweight handoff for OpenCode: once the AI finishes a task, I tell it to run `workflow.sh` with a short summary of what it completed so the script posts that message to Discord as a completion notice.

Example prompt instruction:

```text
When you're done, run ./workflow.sh "Finished the task: reviewed the project, updated the docs, and validated the shell scripts."
```

The idea is simple: finish the task, then send a quick summary so the notification tells me what happened without needing a long log.

## Important

- Anything here may be incomplete, temporary, or tailored to my personal use.
- Always review commands and requirements before running anything.
- The main goal is to keep work practical, lightweight, and easy to trigger from the prompt.
