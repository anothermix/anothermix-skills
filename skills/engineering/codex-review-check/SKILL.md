---
name: codex-review-check
description: Fetch the Codex code-review comments on a GitHub PR, then adjudicate each finding against the real code in the local repo and report — in Thai — whether it is valid, with a small/medium/large effort estimate for the fix. Trigger on /codex-review-check and whenever the user asks to check, verify, validate, หรือ "จริงไหม" a Codex (chatgpt-codex-connector) review on a PR, review Codex feedback, or decide which Codex comments are worth acting on. Use this even if the user only says "เช็ค codex review PR นี้ให้หน่อย" without naming the skill.
---

# Codex Review Check

Codex (`chatgpt-codex-connector[bot]`) leaves inline review comments and a PR-level summary on GitHub PRs. Codex is fast but **not always right** — it posts false positives, flags things already handled elsewhere, and sometimes proposes fixes that don't apply cleanly. This skill's job is to stand between Codex and the user: fetch what Codex said, verify each finding against the *actual* code in the local repo, and report which findings are real and how big the fix is — so the user reads a short verdict list instead of chasing every bot comment.

**Report in Thai.** Adjudication is technical, but the write-up the user reads is Thai.

## Operating stance

- **The Codex comment is a claim, not a fact.** Every finding starts as "Codex says X." It becomes valid only after you trace the real code and confirm it. Keep "Codex says X" and "I traced X and it holds / doesn't hold" separate.
- **Trace real code, not just the diff.** The diff is the entry point. Follow the call path into unchanged code on either side — Codex often misses that the concern is already handled upstream/downstream, or conversely that the bug reaches further than the changed lines.
- **Honest verdicts.** A finding can be ไม่จริง (false positive). Say so plainly with evidence. No rubber-stamping Codex, no inventing agreement.
- **Report only, by default.** Do NOT auto-fix, push commits, or reply/post back to the PR. Just report for the user to read. Only fetch (read); take a write action solely if the user explicitly asks in a later message.

## Workflow

Run in order. Do not skip ahead to the report before tracing.

### 1. Resolve the PR

Get `owner`, `repo`, `number`. If the user gave a PR number or URL, use it. Otherwise infer from the current branch:

```bash
gh repo view --json nameWithOwner -q .nameWithOwner        # OWNER/REPO
gh pr view --json number,url,headRefName -q '{number,url,headRefName}'
```

If no PR is found for the branch, say so and ask for the PR number/URL — don't guess.

### 2. Fetch the Codex review

Codex findings live in **review threads** (inline, anchored to lines) plus a **PR-level summary**. On re-reviews only *unresolved* threads still matter, so pull resolved status too. Use GraphQL as the primary source — it returns inline comments **and** `isResolved` in one call:

```bash
gh api graphql -f query='
query($owner:String!,$repo:String!,$num:Int!){
  repository(owner:$owner,name:$repo){
    pullRequest(number:$num){
      reviewThreads(first:100){
        nodes{
          isResolved
          isOutdated
          comments(first:20){ nodes{ author{login} body path line } }
        }
      }
    }
  }
}' -f owner=OWNER -f repo=REPO -F num=NUMBER
```

Then the PR-level summary (a review body or an issue comment, not a thread):

```bash
gh api repos/OWNER/REPO/pulls/NUMBER/reviews --paginate \
  --jq '.[] | select(.user.login|test("codex";"i")) | {state,body}'
gh api repos/OWNER/REPO/issues/NUMBER/comments --paginate \
  --jq '.[] | select(.user.login|test("codex";"i")) | .body'
```

**Identifying Codex comments:** the canonical login is `chatgpt-codex-connector[bot]`, but the bot's login can differ between REST and GraphQL, and some teams run Codex via a third-party action under a different bot. So match **case-insensitively on a login containing `codex`**, and as a fallback, recognise the body marker (e.g. a "Codex Review" / "💡 Codex Review" header). If the user names a different bot/author, honour that.

**Default scope = unresolved, non-outdated threads.** Note resolved/outdated ones exist but keep them out of the main list unless the user asks to include them. Also extract any ` ```suggestion ` block in a comment — that is Codex's proposed replacement code and feeds both the verdict and the size estimate.

If no Codex comments are found: report that plainly. Possible reasons — Codex reacted 👍 with no findings, the review hasn't finished, or the bot login differs. Suggest the user confirm the review ran (or comment `@codex review`), don't fabricate findings.

### 3. Adjudicate each finding against the real code

For every finding, open the referenced `path` at the referenced line in the local repo and trace it:

- **What exactly does Codex claim?** Restate it in one line.
- **Trace the real path.** Entry → call sites → branches → state/return. Read the code around the diff, not only the changed lines.
- **Compare current code vs. Codex's proposed fix** (the ` ```suggestion ` block or described change). Does the current code actually have the problem? Would the proposed change fix it without breaking callers, tests, or types?
- **Verdict** — one of:
  - **จริง** — confirmed against the code; the concern is real.
  - **ไม่จริง (false positive)** — traced and refuted; explain why (already handled, misread, doesn't apply to this path).
  - **จริงบางส่วน / ต้องดูเพิ่ม** — real under some inputs/paths, or can't be fully verified without info you don't have (name what's missing).
- **Evidence** — cite `file:line` and the trace step that decided it. No vague "อาจจะพัง".

### 4. Size the fix

Estimate effort to *actually* apply the fix in this repo — based on the diff between current code and the proposed change, plus ripple (callers, types, tests):

- **small** — จุดเดียว/ไฟล์เดียว ไม่กี่บรรทัด เชิงกลไก (null/guard check, rename, typo, ปรับเงื่อนไขเล็ก) ไม่กระทบ interface หรือ test
- **medium** — หลายไฟล์ หรือแก้ logic ที่ต้องปรับ test ด้วย หรือ refactor เล็กในขอบเขตจำกัด
- **large** — กระทบข้าม module / เปลี่ยน contract หรือ API / ต้องแก้หลายจุดที่พึ่งพากัน / ขอบเขตยังไม่ชัดต้องออกแบบเพิ่ม

For ไม่จริง findings, size is not applicable — mark `—`.

### 5. Report (ภาษาไทย)

Lead with a one-line summary, then the list ordered by severity (blocker → major → nit), แล้วปิดท้ายด้วย verdict. Use this structure:

```markdown
## สรุป Codex review — PR #<number>

พบ <N> finding จาก Codex · จริง <x> · ไม่จริง <y> · ต้องดูเพิ่ม <z>
แรงที่ต้องลง (เฉพาะที่จริง): small <a> · medium <b> · large <c>

---

### 1. <หัวข้อ finding สั้นๆ> — `path:line`
- **Codex ว่า:** <สิ่งที่ Codex อ้าง หนึ่งประโยค>
- **ผลตรวจ:** ✅ จริง | ❌ ไม่จริง | ⚠️ จริงบางส่วน
- **หลักฐาน:** <trace / เหตุผลอ้างอิงโค้ดจริง file:line>
- **ถ้าจะแก้:** <วิธีแก้ที่เล็กที่สุด> — **ขนาด: small | medium | large**

### 2. ...

---

**คำตัดสิน:** <ควรแก้อะไรก่อน / อะไรข้ามได้ / เหลืออะไรที่ต้องถามคนเขียน PR> — เหตุผลหลักหนึ่งบรรทัด
```

## Operating rules

- **Cite or it didn't happen.** Every verdict points to a real `file:line` or trace step. "Codex อ้าง" กับ "trace แล้วยืนยัน/ค้าน" ต้องแยกกันชัด.
- **False positives are a finding too.** Calling out a wrong Codex comment saves the user more time than confirming a right one — don't soften it.
- **Size reflects reality, not the comment length.** A one-line Codex nit can be `large` if the fix ripples; a scary-sounding one can be `small`. Judge from the trace.
- **Don't act on the PR.** Read-only by default. Posting a reply, resolving a thread, pushing a fix, or commenting `@codex` are separate actions that need the user to ask for them explicitly first.
- **No padding.** If a finding is a trivial style nit and there's a real bug in the list, lead with the bug and keep the nit to one line.
