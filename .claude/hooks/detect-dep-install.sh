#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# PostToolUse hook — detects package installs in devcontainer projects.
# Receives a JSON blob on stdin with tool_input.command; writes a reminder
# to stdout, which Claude Code injects into the conversation context.
#
# Register in .claude/settings.json:
#   "hooks": {
#     "PostToolUse": [{
#       "matcher": "Bash",
#       "hooks": [{"type": "command", "command": "bash .claude/hooks/detect-dep-install.sh"}]
#     }]
#   }

# Only relevant if this project has a devcontainer
[ -d ".devcontainer" ] || exit 0

COMMAND=$(python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except Exception:
    pass
" 2>/dev/null)

[ -z "$COMMAND" ] && exit 0

# Match common package manager install patterns
if echo "$COMMAND" | grep -qE \
  '(apt-get install|apt install|pip install|pip3 install|npm install|npm i |cargo add|go get|brew install)'; then
  echo "[devenv] Package install detected in a devcontainer project. If this dependency will be needed by teammates or after a rebuild, suggest adding it to .devcontainer/postCreate.sh."
fi
