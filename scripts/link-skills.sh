#!/usr/bin/env bash
# Symlink every skill in this repo into ~/.claude/skills/ so Claude Code picks them up.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${HOME}/.claude/skills"
mkdir -p "$TARGET_DIR"

find "$REPO_ROOT/skills" -name SKILL.md -not -path "*/in-progress/*" | while read -r skill_md; do
  skill_dir="$(dirname "$skill_md")"
  skill_name="$(basename "$skill_dir")"
  link="$TARGET_DIR/$skill_name"
  if [ -e "$link" ] && [ ! -L "$link" ]; then
    echo "skip  $skill_name (already exists and is not a symlink)"
    continue
  fi
  ln -sfn "$skill_dir" "$link"
  echo "link  $skill_name -> $skill_dir"
done
