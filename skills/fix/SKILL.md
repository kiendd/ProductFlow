---
name: fix
description: Use when a bug is reported — the code does something the product was never meant to do. Fast lane: reproduce, fix, then check the PRD; if the scenario, requirement, or PRD that should have caught it is missing, open a short proposal and archive it.
---

# Fixing a bug

Fast lane. Three moves, in order: **reproduce → fix → check the PRD.** Only when the PRD check
finds a gap do you open a change folder — a short one, written after the fact, because the code
is already right and the docs need to catch up.

The lane is fast because the intended behavior does not move. The moment it does, you are no
longer fixing — stop and go to `productflow:propose`.

Format questions go to `productflow:prd`.

## Step 1 — Is it a bug? (30 seconds)

Read `docs/product/index.md`, open the domain `PRD.md` it points to, and find the requirement
whose `**Statement**` governs the behavior. One of three outcomes:

| Outcome | Verdict |
|---|---|
| A requirement states the correct behavior; the code violates it | **Bug.** Continue |
| No requirement covers it, and any reader would call the current behavior wrong — crash, wrong total, data loss, stale display, lying error message | **Bug.** Continue |
| A requirement states the behavior the code has, or "correct" needs arguing | **Behavior change.** Stop → `productflow:propose` |

Say which row you picked in one line. Then move.

## Step 2 — Reproduce, then fix

1. Write a test that fails for the reason reported. Run it. Read the red output.
   Cannot reproduce after a fair attempt → report the exact steps tried and stop.
2. Make the smallest change that turns it green. Run the test again. Read the output.
3. Run the project's test suite. Read the output. Red anywhere → not done.
4. Commit: `fix: <what was wrong> (<REQ-ID>)` — the ID from Step 1, or `no-req` if none
   covered it yet; Step 4 allocates one.

Not on `main`/`master` without agreement; `fix/<slug>` is fine.

Noticed a second bug on the way? Do not fix it here. Name it in your report.

## Step 3 — Quick PRD check

The bug slipped through because the docs did not pin the behavior down. Find the gap:

| What is missing | Next |
|---|---|
| Nothing — a scenario already describes exactly this case | Done. Skip to Report |
| The requirement exists but has no scenario for this case | Step 4, bucket `MODIFIED` |
| No requirement covers this behavior | Step 4, bucket `ADDED` |
| No PRD for this domain | Step 4, bucket `ADDED`, `**Target**` is the PRD that *should* exist |
| No `docs/product/` at all | `../productflow/scripts/pf-init`, then the row above |

## Step 4 — Short proposal, written after the fact

One change folder, filled in one pass, no design, no question rounds. The code is done; this
records what it proved.

```bash
../productflow/scripts/pf-new-change fix-<slug>
```

**`change.md`** — four lines of prose, one each:

- `## Why` — what was observed, what was expected, which requirement it violated (or "none
  covered it").
- `## What Changes` — "Code now matches `<REQ-ID>`; docs gain the scenario/requirement that
  proves it."
- `## Scope` — in: this behavior. Out: anything you noticed and left alone.
- `## Impact` — the code file and the test from Step 2.
- `domains:` — the owning domain. `status: implemented`.

**`requirements.md`** — exactly one entry, in the `prd_locale` language:

- `MODIFIED` — restate the whole requirement verbatim (heading, `**Status**`, `**Statement**`,
  every existing scenario) and add one scenario named after the bug. `**Statement**` unchanged.
- `ADDED` — `../productflow/scripts/pf-reqid <domain> --count 1`, then `**Target**: <PRD id>`,
  one `**Statement**`, one scenario. Target does not exist yet → derive its id from the path it
  will live at (`docs/product/billing/PRD.md` → `product.billing`); `productflow:archive` creates
  the file when it merges.

```markdown
#### Scenario: Hóa đơn đã hủy không tính vào tổng
- **WHEN** khách hàng có một hóa đơn đã hủy trong kỳ
- **THEN** tổng kỳ không bao gồm hóa đơn đó
```

**`tasks.md`** — one task, already ticked, because Step 2 did the work:

```markdown
## 1. Fix

- [x] 1.1 <what the code does now> — verify: `<the command from Step 2>`
  - Requirements: <REQ-ID>
  - Files: modify `<code path>`, create|modify `<test path>`
  - Steps: test đỏ → sửa tối thiểu → xanh → full suite xanh → commit <sha>
```

Create `.productflow/runs/fix-<slug>/progress.md` with two lines: the ledger header and
`Task 1.1: complete — <sha>`.

Run `../productflow/scripts/pf-validate`; fix every `error`.

**Show, then archive.** One message: the REQ ID, its bucket, the statement, the new scenario,
and the target PRD — marked *will be created* when it does not exist. The user says yes → hand
off to `productflow:archive` in the same session. Its step 1 re-runs your test; its step 2
creates the PRD when the target is new. The user says no → they are telling you the behavior is
in dispute; this is `productflow:propose`.

### Where the fast lane ends

Any of these means it was never a bugfix. Do not open the short proposal — go to
`productflow:propose`:

- You had to change an existing `**Statement**` to make the docs agree with your fix.
- You had to write a `**Statement**` you would defend rather than state.
- The fix touched two or more domains' PRDs.
- The fix needed a design decision the requirement does not settle.

## Report

Four lines:

- What was wrong, what the code does now, commit sha.
- Regression test path and the command that runs it.
- PRD gap: *none* — or `<REQ-ID>` (`ADDED` / `MODIFIED`), the archive path, and the PRD it
  landed in, marked **created** if this fix created it. Created a PRD or ran `pf-init` → say the
  repo needs `productflow:onboard` for the rest.
- Anything noticed and deliberately left alone.
