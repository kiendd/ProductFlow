---
name: update
description: Use when an existing change's proposal, requirements, design, or tasks no longer match reality and must be revised before work continues.
---

# Updating a change

Revise the three artifacts in `docs/changes/<slug>/` so they describe reality again.

**This skill never touches code.** It edits `change.md` (including its `## Design` and
`## Outcome` sections), `requirements.md`, `tasks.md`, and appends notes to
`.productflow/runs/<slug>/progress.md`. Nothing else.

## Step 1 — Confirm this is your job

Five kinds of revision belong here:

1. Add or remove a requirement — including a "case", "scenario", or "edge case" that asserts
   behavior no existing `**Statement**` covers.
2. Change a requirement's `**Statement**`.
3. Change `## Scope` in `change.md`.
4. Reverse a decision in the `## Design` section.
5. Add a new `## <n>` task group.

Everything smaller belongs to `productflow:apply`, which handles it without a review cycle:
adding or clarifying a scenario that only illustrates behavior an existing `**Statement**`
already asserts, rewording a task or its `— verify:` command, splitting a task into two
sub-tasks with the same scope, correcting a wrong path on a `Files:` line.

**The test that separates the two**: does an existing `**Statement**` already assert the
behavior? Yes → small, apply's job. No → the requirement is missing that behavior, so this is
item 1 above and belongs here, however the user phrased it.

Called for one of those small items → say so and hand straight back to `productflow:apply`.
Opening an approval cycle for a typo wastes the user's turn.

An **archived** change is never updated. Anything after archive goes through
`productflow:propose` as a new change.

## Step 2 — Update, or start a new change?

Answer three questions:

1. Same intent — is the new work solving the same problem as the original change?
2. Does the new scope overlap the old scope by more than half?
3. Would the original change be incomplete if the new part were dropped?

Two or more "no" → this is a new change, not an update.

Starting a new change: if the current one already has working, verified pieces, archive it first
with `productflow:archive`, then run `productflow:propose`. If it has nothing usable, agree with
the user to abandon it before proposing.

## Step 3 — Propagate, in both directions

A revision in one artifact is never done alone. Check the others every time.

| Revised | Must also check |
|---|---|
| `## Scope` in `change.md` | Every requirement in the delta that now falls outside the new scope |
| A requirement added | `tasks.md` — it needs at least one task covering it |
| A requirement removed | `tasks.md` — tasks pointing at it must go; `## Design` decisions that only existed for it |
| A `**Statement**` changed | Tasks whose `— verify:` command no longer proves the statement |
| A decision in `## Design` | Tasks that decision governs; and if the decision changes observable behavior, `requirements.md` too |
| A task group added | `requirements.md` — the group must trace to real REQ IDs |

Also check backwards: a task you are adding that traces to no requirement means a requirement is
missing, not that the task needs no ID.

## Step 4 — Handle already-completed tasks

A task ticked `- [x]` that is no longer correct:

- **Never delete the line.** History of what was done stays visible.
- Untick it back to `- [ ]`.
- Append ` (revised <YYYY-MM-DD>)` to the task text.
- Add a line to `.productflow/runs/<slug>/progress.md` naming the task and why it was reopened.

## Step 5 — Show before you write

Present every edit to the user — which file, which section, what the new text says, and what it
propagates to. Write only after they agree. This is the review cycle that justifies the skill
existing; skipping it turns `update` into silent drift.

## Step 6 — Close

1. Run `../productflow/scripts/pf-validate`; fix every `error`.
2. The change was `implemented` and the delta just changed → set `status: in-progress` and hand
   off to `productflow:apply` so the code catches up.
3. Otherwise → hand back to the skill that called you, at the point it stopped.
