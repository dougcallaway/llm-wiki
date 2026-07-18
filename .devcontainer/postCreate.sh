#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -euo pipefail

# -- Claude skills: git repos cloned into ~/.claude/skills/ --
CLAUDE_SKILL_REPOS=(
  # "https://github.com/org/skill-name"
)

# -- Claude skills: marketplace plugins --
CLAUDE_SKILL_MARKETPLACES=(
  # "plugin-name@marketplace-name"
)

echo "==> [1/3] Fixing volume ownership"
sudo chown -R vscode:vscode /home/vscode/.claude

echo "==> [2/3] Installing Claude skill repos"
if (( ${#CLAUDE_SKILL_REPOS[@]} > 0 )); then
  mkdir -p /home/vscode/.claude/skills
  for url in "${CLAUDE_SKILL_REPOS[@]}"; do
    skill_name=$(basename "$url" .git)
    target="/home/vscode/.claude/skills/${skill_name}"
    if [ -d "$target" ]; then
      git -C "$target" pull --ff-only
    else
      git clone --depth 1 "$url" "$target"
    fi
  done
fi

echo "==> [3/3] Installing Claude marketplace skills"
for plugin in "${CLAUDE_SKILL_MARKETPLACES[@]+"${CLAUDE_SKILL_MARKETPLACES[@]}"}"; do
  claude plugin install "$plugin" --scope user
done

echo "==> postCreate complete"
