# Telegram

This folder contains small Telegram-related utilities I created for personal automation tasks, experimentation, and quick workflow helpers.

It is not an official library or a production-ready project. It is mainly a personal collection of scripts that help me with specific tasks such as inspecting bot data, finding chat IDs, or testing Telegram integrations.

## Included script

### telegram_get_chat_id.sh

[`telegram_get_chat_id.sh`](telegram_get_chat_id.sh) queries the Telegram Bot API and lists the chat IDs from recent updates received by a bot.

It is useful when you need to know which chat, group, or channel a bot is receiving messages from. Only recent updates returned by `getUpdates` are inspected, so send a message to the bot (or add it to a group/channel and write something there) before running it.

Typical usage from this folder:

```bash
bash telegram_get_chat_id.sh <BOT_TOKEN>
```

Or from the repository root:

```bash
bash Telegram/telegram_get_chat_id.sh <BOT_TOKEN>
```

You can also export the token instead of passing it as an argument:

```bash
export TELEGRAM_BOT_TOKEN="123456:ABC..."
bash Telegram/telegram_get_chat_id.sh
```

## Requirements

- `curl`
- `jq`

Install them if needed:

```bash
sudo apt install -y curl jq
```

## Important notes

- The script is not executable in the repository, so invoke it with `bash` or add the executable bit yourself.
- Review each script before using it.
- Telegram bot tokens are sensitive and should never be committed to a public repository. Passing the token as a command-line argument may also expose it in shell history or process listings; exporting `TELEGRAM_BOT_TOKEN` is preferable on shared machines.
- This folder is for practical personal use and experimentation, not for a universal Telegram solution.
