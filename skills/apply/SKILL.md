---
name: apply
description: Use when a change folder has tasks.md with unchecked tasks and implementation should start or resume.
---

# Applying a plan

Execute `tasks.md` in order, with evidence for every completed task.

## Step 1 — Pick the mode and announce it

| Harness | Mode | Shape |
|---|---|---|
| Can dispatch subagents | **subagent** | One fresh agent per task, a review after each task, one overall review at the end |
| Cannot | **inline** | Sequential in this session, checkpoint with the user after each `## <n>` group |

Announce the mode you chose and why. The user may force the other one.

Subagent mode uses `implementer-prompt.md` and `reviewer-prompt.md` from this skill directory.

## Step 2 — Set up the branch and the ledger

Never start on `main` or `master` without explicit agreement. Propose `change/<slug>`.

Set `status: in-progress` in `change.md` before touching a task — on first entry, and again
whenever you re-enter a change that reads `implemented`, such as after `productflow:archive`
sends work back. A change with ticked boxes still reading `planned` misreports itself in
`manifest.json`.

Create `.productflow/runs/<slug>/progress.md`, first line:

```
# ProductFlow ledger — change: <slug>
```

The ledger is append-only, and it outranks your memory. Write to it as you go:

```
Task 1.1: complete — a1b2c3d
Ruling: dùng Buffer thay vì stream — API hiện tại đồng bộ — nếu sai thì phải sửa lại chữ ký hàm
```

Resuming a session: read the ledger and `git log`, not your recollection. Restart at the first
task with no `complete` line, regardless of what the checkboxes say.

## Step 3 — Execute one task at a time

For each unchecked task, in order:

1. Read the task's four parts. Anything unclear → resolve it before writing code.
2. Follow `Steps:`, test-first where a test is possible.
3. Run the exact command in `— verify:`.
4. Read the output. Success in this turn is the only thing that permits a tick.
5. Tick `- [x]`, commit, append `Task <n.m>: complete — <sha>` to the ledger.

Never tick a checkbox from expectation, from "it should pass", or from a previous run. No
observed successful output means the task is not done.

## Step 4 — Decide, or stop and ask

Stop and ask the user in exactly four situations:

| Situation | Example |
|---|---|
| Irreversible or destructive | Dropping a table, deleting files outside the worktree, force-pushing |
| Security-sensitive | Touching auth, credentials, permissions, crypto |
| Side effects outside the worktree | Merging, pushing to a shared branch, publishing, calling a paid API |
| The plan is broken beyond repair | Every remaining path is a guess |

Everything else: decide, act, and write a `Ruling:` line naming the decision, the reason, and
the cost if it turns out wrong.

## Step 5 — Small fix here, large change via update

Hard boundary. Do not reason around it.

**The test that decides it**: does the existing `**Statement**` already assert the behavior in
question? Yes → the scenario only illustrates what the requirement already says: small. No → you
are adding a behavior the requirement does not cover: that is a new requirement, large, however
the user phrased it. "A cancelled invoice must not be downloadable" is a new prohibition, so it
is large even though it reads like a scenario.

**Small — fix it yourself and continue:**

- Add, edit, or clarify a `#### Scenario` that only illustrates behavior the existing
  `**Statement**` already asserts.
- Reword a task, or correct its `— verify:` command.
- Split one task into two sub-tasks with the same scope.
- Correct a wrong path on a `Files:` line.

Each of these: make the edit, append one `Ruling:` line, run
`../productflow/scripts/pf-validate`, keep going. Do not ask, do not break the flow.

**Large — stop and call `productflow:update`:**

- Add or remove a requirement — including a "case", "scenario", or "edge case" that asserts
  behavior no existing `**Statement**` covers.
- Change a requirement's `**Statement**`.
- Change `## Scope` in `change.md`.
- Reverse a decision in `design.md`.
- Add a new `## <n>` task group.

After `update` finishes and the user approves, come back and resume at the task you were on.

Unsure which side of the line it falls on → treat it as large.

Never quietly change the code to avoid a documentation mismatch. The mismatch is the signal.

## Step 6 — Close out

1. Every checkbox in `tasks.md` is `- [x]` with a matching ledger line.
2. Run the project's full test suite; read the output.
3. Set `status: implemented` in `change.md`.
4. Run `../productflow/scripts/pf-validate`; fix every `error`.
5. Hand off to `productflow:archive`.

Tests failing at step 2 means the change is not implemented. Fix them here; archiving cannot
start on a red suite.
