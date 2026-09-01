# anothermix-skills

Agent skills I wrote for Claude Code — my own dev loop, shipped.

## Layout

Skills live under `skills/`, grouped into buckets:

- `engineering/` — daily code work
- `productivity/` — daily non-code workflow tools
- `in-progress/` — drafts not yet ready to ship

Each skill is its own directory containing a `SKILL.md` (with YAML frontmatter — `name` and `description`) plus any bundled scripts or reference files.

## Install

### With `npx skills` (works for every agent)

```bash
npx skills add anothermix/anothermix-skills
```

### Alternative — symlink into Claude Code

Symlink every skill into `~/.claude/skills/`:

```bash
./scripts/link-skills.sh
```

List every `SKILL.md` in the repo:

```bash
./scripts/list-skills.sh
```

## Reference

### Engineering

- **[codex-review-check](./skills/engineering/codex-review-check/SKILL.md)** — Fetch the Codex (`chatgpt-codex-connector`) review comments on a GitHub PR, adjudicate each finding against the real code in the local repo, and report — in Thai — which findings are valid, with a small/medium/large effort estimate for each fix. Codex is fast but not always right; this skill stands between the bot and you.
- **[pr-hight-level](./skills/engineering/pr-hight-level/SKILL.md)** — Transforms implementation details into a clear, reviewer-friendly GitHub Pull Request description: problem, solution, architecture, scope, testing, and a suggested review order. Readable in under 5 minutes.

### Productivity

_(none yet)_

## Skills I use (authored elsewhere)

Not redistributed here — installed from their original sources:

- **[debug-mantra](https://github.com/thananon/9arm-skills/blob/main/skills/engineering/debug-mantra/SKILL.md)** and **[scrutinize](https://github.com/thananon/9arm-skills/blob/main/skills/engineering/scrutinize/SKILL.md)** — from [thananon/9arm-skills](https://github.com/thananon/9arm-skills)
- **[karpathy-guidelines](https://github.com/forrestchang/andrej-karpathy-skills)** — behavioral guidelines to reduce common LLM coding mistakes

## License

[MIT](./LICENSE)
