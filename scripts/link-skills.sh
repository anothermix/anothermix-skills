#!/usr/bin/env bash
# Symlink every skill in this repo into each agent's user-level skills dir:
#   ~/.claude/skills  (Claude Code)
#   ~/.agents/skills  (Codex and other agents following the .agents convention)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIRS=("${HOME}/.claude/skills" "${HOME}/.agents/skills")

for target_dir in "${TARGET_DIRS[@]}"; do
  mkdir -p "$target_dir"
  find "$REPO_ROOT/skills" -name SKILL.md -not -path "*/in-progress/*" | while read -r skill_md; do
    skill_dir="$(dirname "$skill_md")"
    skill_name="$(basename "$skill_dir")"
    link="$target_dir/$skill_name"
    if [ -e "$link" ] && [ ! -L "$link" ]; then
      echo "skip  $link (already exists and is not a symlink)"
      continue
    fi
    ln -sfn "$skill_dir" "$link"
    echo "link  $link -> $skill_dir"
  done
done
