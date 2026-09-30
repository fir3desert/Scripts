# Telegram

This folder contains small Telegram-related utilities I created for personal automation tasks, experimentation, and quick workflow helpers.

It is not an official library or a production-ready project. It is mainly a personal collection of scripts that help me with specific tasks such as inspecting bot data, finding chat IDs, or testing Telegram integrations.

## Included script

### telegram_get_chat_id.sh

This script queries the Telegram Bot API and lists the chat IDs from recent updates received by a bot.

It is useful when you need to know which chat, group, or channel a bot is receiving messages from.

Typical usage:

```bash
./telegram_get_chat_id.sh <BOT_TOKEN>
```

Or by exporting the token:

```bash
export TELEGRAM_BOT_TOKEN="123456:ABC..."
./telegram_get_chat_id.sh
```

## Requirements

- `curl`
- `jq`

Install them if needed:

```bash
sudo apt install -y curl jq
```

## Important notes

- Review each script before using it.
- Telegram bot tokens are sensitive and should never be committed to a public repository.
- This folder is for practical personal use and experimentation, not for a universal Telegram solution.
