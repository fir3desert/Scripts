#!/usr/bin/env bash
#
# get_telegram_chatid.sh
# Gets the chat_id or chat_ids of the latest messages received by a Telegram bot.
#
# Requirements: curl, jq
#   sudo apt install -y curl jq
#
# Usage:
#   ./get_telegram_chatid.sh <BOT_TOKEN>
#   or by exporting the variable:
#   export TELEGRAM_BOT_TOKEN="123456:ABC..."
#   ./get_telegram_chatid.sh
#
# Before running it, send a message to your bot (or add it to a group/channel
# and write something there), otherwise getUpdates will return nothing.

set -euo pipefail

TOKEN="${1:-${TELEGRAM_BOT_TOKEN:-}}"

if [[ -z "$TOKEN" ]]; then
    echo "Error: bot token was not provided." >&2
    echo "Usage: $0 <BOT_TOKEN>   or   export TELEGRAM_BOT_TOKEN=<token>" >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "Error: 'jq' is missing. Install it with: sudo apt install -y jq" >&2
    exit 1
fi

API_URL="https://api.telegram.org/bot${TOKEN}/getUpdates"

echo "Checking updates..."
RESPONSE="$(curl -s "$API_URL")"

OK="$(echo "$RESPONSE" | jq -r '.ok')"
if [[ "$OK" != "true" ]]; then
    echo "Error in the Telegram API response:" >&2
    echo "$RESPONSE" | jq . >&2
    exit 1
fi

COUNT="$(echo "$RESPONSE" | jq '.result | length')"

if [[ "$COUNT" -eq 0 ]]; then
    echo "No new messages were found."
    echo "Send a message to the bot (or add it to a group/channel and write something there) and run the script again."
    exit 0
fi

echo ""
echo "Chats found:"
echo "-------------------------------------------"

echo "$RESPONSE" | jq -r '
  .result[]
  | (.message // .channel_post // empty) as $m
  | select($m != null)
  | "chat_id: \($m.chat.id)\ttype: \($m.chat.type)\tname: \($m.chat.title // $m.chat.username // $m.chat.first_name // "N/A")"
' | sort -u

echo "-------------------------------------------"
echo "Use the chat_id that matches your chat/group/channel."
