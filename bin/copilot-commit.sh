#!/usr/bin/env bash
set -euo pipefail

APPS_JSON="$HOME/.config/github-copilot/apps.json"

# Get OAuth token stored by copilot.vim
OAUTH_TOKEN=$(python3 -c "
import json
d = json.load(open('$APPS_JSON'))
print(list(d.values())[0]['oauth_token'])
" 2>/dev/null) || {
  echo "Error: copilot.vim token not found. Run :Copilot setup in nvim first." >&2
  exit 1
}

# Exchange for a short-lived Copilot session token
RESPONSE=$(curl -sf \
  -H "Authorization: token $OAUTH_TOKEN" \
  -H "Accept: application/json" \
  -H "Editor-Version: Neovim/0.11.7" \
  -H "Editor-Plugin-Version: CopilotVim/1.35.0" \
  "https://api.github.com/copilot_internal/v2/token") || {
  echo "Error: Could not get Copilot session token." >&2
  exit 1
}

COPILOT_TOKEN=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")
API_EP=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['endpoints']['api'])")

# Bail if nothing is staged
if [ -z "$(git diff --cached --name-only)" ]; then
  echo "Error: No staged changes." >&2
  exit 1
fi

DIFF=$(git diff --cached --stat && printf '\n---\n' && git diff --cached)

# Call Copilot chat completions
CHAT_RESPONSE=$(curl -s \
  -w "\n%{http_code}" \
  -X POST \
  -H "Authorization: Bearer $COPILOT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Editor-Version: Neovim/0.11.7" \
  -H "Editor-Plugin-Version: CopilotVim/1.35.0" \
  "$API_EP/chat/completions" \
  -d "$(jq -n \
    --arg diff "$DIFF" \
    '{
      model: "gpt-4o",
      temperature: 0.1,
      max_tokens: 120,
      messages: [
        {
          role: "system",
          content: "Generate a concise git commit message in conventional commits format: type(scope): description. Output only the commit message. No quotes, no markdown, no explanation."
        },
        {
          role: "user",
          content: ("Generate a commit message for this diff:\n\n" + $diff)
        }
      ]
    }')")

HTTP_CODE=$(echo "$CHAT_RESPONSE" | tail -n1)
BODY=$(echo "$CHAT_RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "429" ]; then
  echo "Error: GitHub Copilot quota exceeded. Please check your Copilot subscription." >&2
  exit 1
elif [ "$HTTP_CODE" != "200" ]; then
  echo "Error: API returned status $HTTP_CODE" >&2
  echo "$BODY" >&2
  exit 1
fi

echo "$BODY" | jq -r '.choices[0].message.content | ltrimstr("\n") | rtrimstr("\n")'
