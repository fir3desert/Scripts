#!/bin/bash

DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/REPLACE_WITH_YOUR_WEBHOOK_ID/REPLACE_WITH_YOUR_TOKEN"
MESSAGE="${1:-./workflow.sh finished successfully}"

curl -fsSL -X POST \
  -H "Content-Type: application/json" \
  --data "{\n  \"content\": \"$MESSAGE\"\n}" \
  "$DISCORD_WEBHOOK_URL"

