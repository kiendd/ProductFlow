---
name: plan
description: Use when a change folder has an approved proposal and delta requirements but no task list yet.
---

# Planning a change

Turn an agreed delta into a task list a fresh agent could execute without asking questions.

## Entry conditions

`docs/changes/<slug>/change.md` and `requirements.md` both exist and are agreed. Either is
missing → go back to `productflow:propose`.

## Step 1 — Decide on design.md

Write `design.md` when the change is **architectural** — that is, when at least one of the
criteria in `productflow:propose` Step 2 holds:

- The change touches two or more modules or services.
- It adds an external dependency.
- It changes the data model.
- It carries a security, performance, or migration constraint.

None of them holds and `pf-new-change --design` already created the file → delete it. An empty
design document is noise that later readers will mistake for a decision record.

When you do write it, use the five sections: `Context`, `Decisions`, `Risks & Trade-offs`,
`Migration`, `Open Questions`. Each decision states the option chosen, the options rejected, and
why.

## Step 2 — File map before tasks

List every file to create or modify, and the one responsibility of each. Prefer many small
single-responsibility files over one large one.

| File | Responsibility |
|---|---|
| `src/billing/pdf.ts` | Render an issued invoice into a PDF buffer |
| `tests/billing/pdf.test.ts` | Prove the PDF carries the invoice number and total |

Only after the map is stable do you write tasks. Tasks written before the map drift into
"and also touch this file" additions.

## Step 3 — Size the tasks

A task is the smallest unit that has its own test cycle and that a reviewer could reject on its
own. Setup, configuration, and documentation are folded into the task that needs them — never
split off as their own checkbox.

Group tasks under `## <n>. <group name>` headings in dependency order.

## Step 4 — Write every checkbox in full

```markdown
- [ ] 1.1 Thêm hàm render PDF — verify: `pnpm test invoice-pdf`
  - Requirements: REQ-BILLING-001
  - Files: create `src/billing/pdf.ts`, create `tests/billing/pdf.test.ts`
  - Steps: viết test đỏ → chạy thấy fail → implement tối thiểu → chạy xanh → commit
```

Four parts, all mandatory:

- `— verify:` — the exact command to run, copy-pasteable, not a description of one.
- `Requirements:` — real IDs that exist in `requirements.md`.
- `Files:` — the files this task touches, with `create` or `modify`.
- `Steps:` — the sequence, test-first where a test is possible.

### Banned placeholders

Each of these is a planning defect, not a style preference:

| Pattern | Why it fails |
|---|---|
| "TBD", "to be decided" | The executor has to re-plan mid-execution |
| "handle errors appropriately" | Nobody can tell whether it was done |
| "similar to task 2.1" | The reader must reconstruct your intent |
| "add tests" with no named behavior | Produces a test that asserts nothing |
| `— verify: run the tests` | Not a command |
| A requirement ID that is not in the delta | Breaks traceability at archive time |

## Step 5 — Self-review

1. Every requirement in the delta is covered by at least one task.
2. Every function, type, or endpoint used by a later task is created by an earlier one.
3. Every `Files:` path is consistent with the file map.
4. Every `— verify:` command exists in this repository's tooling.
5. Set `status: planned` in `change.md`.
6. Run `../productflow/scripts/pf-validate`; fix every `error`.

## Step 6 — Hand off

Ask the user which execution mode they want, then hand off to `productflow:apply`:

- **Subagent** — a fresh agent per task with a review after each. Better isolation, more tokens.
- **Inline** — sequential in this session with a checkpoint after each `## <n>` group. Cheaper,
  and the only option when the harness cannot dispatch subagents.
