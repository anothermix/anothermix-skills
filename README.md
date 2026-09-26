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

### Alternative — symlink into Claude Code and Codex

Symlink every skill into `~/.claude/skills/` (Claude Code) and `~/.agents/skills/` (Codex). Edits in this repo show up in both immediately:

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

- **[req-gathering](./skills/productivity/req-gathering/SKILL.md)** — Full requirement-gathering workflow for any project: bootstrap an Airtable requirement tracker, turn Fireflies meeting transcripts into tracked requirements + open questions (with dedup and conflict detection), and generate a functional spec from the tracker. The tracker is the single source of truth; documents are generated, never hand-edited. Per-project repo scaffold available at [req-harness-template](https://github.com/anothermix/req-harness-template).

## Adapted from elsewhere

Copied here so every agent on my machines reads from one place. Credit and license stay with the original authors:

- **[debug-mantra](./skills/engineering/debug-mantra/SKILL.md)** and **[scrutinize](./skills/engineering/scrutinize/SKILL.md)** — from [thananon/9arm-skills](https://github.com/thananon/9arm-skills)
- **[pr](./skills/engineering/pr/SKILL.md)** — adapted from `show-me` by Dex Horthy, [humanlayer/skills](https://github.com/humanlayer/skills)
- **[karpathy-guidelines](https://github.com/forrestchang/andrej-karpathy-skills)** — installed as a plugin, not copied

## License

[MIT](./LICENSE)
