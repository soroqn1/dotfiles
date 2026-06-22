#!/usr/bin/env bash
set -euo pipefail

# Get GitHub token via gh CLI
GITHUB_TOKEN=$(gh auth token 2>/dev/null) || {
  echo "Error: gh not authenticated. Run: gh auth login" >&2
  exit 1
}

# Exchange for a Copilot session token
COPILOT_TOKEN=$(curl -sf \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/json" \
  -H "Editor-Version: Neovim/0.11.7" \
  -H "Editor-Plugin-Version: CopilotVim/1.35.0" \
  "https://api.github.com/copilot_internal/v2/token" | jq -r '.token') || {
  echo "Error: Could not get Copilot token. Check your Copilot subscription." >&2
  exit 1
}

# Bail if nothing is staged
if [ -z "$(git diff --cached --name-only)" ]; then
  echo "Error: No staged changes." >&2
  exit 1
fi

DIFF=$(git diff --cached --stat && printf '\n---\n' && git diff --cached)

# Call Copilot API
curl -sf \
  -X POST \
  -H "Authorization: Bearer $COPILOT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Editor-Version: Neovim/0.11.7" \
  -H "Editor-Plugin-Version: CopilotVim/1.35.0" \
  "https://api.githubcopilot.com/chat/completions" \
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
    }')" | jq -r '.choices[0].message.content | gsub("^[\"'\'']|[\"'\'']$"; "") | ltrimstr("\n") | rtrimstr("\n")'
