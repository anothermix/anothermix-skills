#!/usr/bin/env bash
# List every skill in the repo with its one-line description.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

find "$REPO_ROOT/skills" -name SKILL.md | sort | while read -r skill_md; do
  rel="${skill_md#"$REPO_ROOT"/}"
  name="$(awk -F': ' '/^name:/ {print $2; exit}' "$skill_md")"
  echo "${name:-$(basename "$(dirname "$skill_md")")}  —  $rel"
done
