---
name: archive
description: Use when every task in a change is complete and verified and the change has not been merged into the product docs yet.
---

# Archiving a change

Merge the delta into the PRD tree, then retire the change folder. Follow the steps in order.

Format questions go to `productflow:prd`.

## 1. Verify before merging

The most expensive step, and the one that makes the docs trustworthy. Do not skip it and do not
delegate it to the validator.

For **each** requirement in `requirements.md`:

1. Name the code file that implements it.
2. Name the test file that proves it.
3. Run that test. Read the output.

| Result | Action |
|---|---|
| No code implements the requirement | Stop. Back to `productflow:apply` |
| No test proves the requirement | Stop. Back to `productflow:apply` |
| The test fails | Stop. Back to `productflow:apply` |

Also confirm: `tasks.md` has no `- [ ]` left, and the project's full test suite is green in this
session. Keep the code and test paths you collected — step 6 writes them into the PRDs.

## 2. Merge ADDED

For each entry, open the PRD named by `**Target**`.

Target does not exist yet → create it from `../productflow/assets/templates/prd.md`, deriving
`id`, `type`, `domain`, and `parent` from its path.

Insert the requirement into `## Requirements` in **ascending ID order**. Copy the statement and
every scenario verbatim; drop the `**Target**` line, which is delta-only.

## 3. Merge MODIFIED

Match the existing requirement **by ID, never by title**. Replace the whole block — heading,
`**Status**`, `**Statement**`, and all scenarios — with the delta's version. Leftover scenarios
from the old version are a merge bug.

## 4. Merge REMOVED

Delete the requirement block from its PRD. Retired IDs are never reused.

A PRD left with zero requirements: set `status: deprecated` and leave the file in place. Deleting
it breaks every link and every `source_changes` reference pointing at it.

## 5. Merge RENAMED

Keep the ID. Change the title in the `### ` heading and in every reference — most importantly the
`## Implementation Map` rows.

## 6. Update every PRD you touched

- `updated`: today.
- `source_changes`: append `<archive-date>-<slug>`.
- `## Implementation Map`: one row per requirement, with the real code and test paths collected
  in step 1.
- `## Change Log`: one new row — date, change slug, one-line summary.
- `## Summary` and `## Behavior Details`: rewrite the parts this change made untrue. A merged
  requirement sitting under a stale summary misleads the next reader.

## 7. Update the top-level PRD

`docs/product/PRD.md` changes when a new domain appeared or the system-level picture moved.
Nothing changed at that level → leave it alone.

## 8. Write outcome.md

In the change folder, from `../productflow/assets/templates/outcome.md`:

| Section | Content |
|---|---|
| `Shipped` | What a user can now do that they could not before |
| `Requirements merged` | Each REQ ID with its destination PRD id |
| `Deviations from plan` | Where execution differed from `tasks.md`, and why — pull the `Ruling:` lines from `.productflow/runs/<slug>/progress.md` |
| `Commits` | The commit range or list |
| `Follow-ups` | Known gaps, with an owner or "unassigned" |

## 9. Run the tools

```bash
../productflow/scripts/pf-index
../productflow/scripts/pf-validate
../productflow/scripts/pf-archive <slug>
```

Fix every `error` from `pf-validate` before archiving.

`pf-archive` exiting `6` means the merge is incomplete: an ADDED or MODIFIED ID is not in any
PRD, or a REMOVED ID is still there. Go back to steps 2–5. Do not reach for `--force`; it exists
for recovering a broken tree, not for skipping a merge.

## 10. Report

- The archive path: `docs/changes/archive/<date>-<slug>/`.
- Every REQ ID merged, and where it landed.
- Every PRD file that changed.
- Any follow-up recorded in `outcome.md`.
