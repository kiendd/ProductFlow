---
name: onboard
description: Use when a repository has code but no product docs tree, when the docs tree is missing domains that already exist in the code, or when prior OpenSpec or Superpowers documentation should be converted into ProductFlow PRDs.
---

# Onboarding a repository

Build the initial PRD tree from what already exists — the code, and any prior documentation left
behind by another tool. Everything written here starts as `status: draft`: it is a reading of
the evidence, not an agreed specification.

Format questions go to `productflow:prd`.

## Step 1 — Initialize

Ask the user which language the PRDs should be written in, defaulting to `vi`:

```bash
../productflow/scripts/pf-init --locale vi
```

Already initialized (exit `3`) → skip this step and continue with the existing config.

## Step 2 — Look for prior documentation

Check for these before reading any code:

| Found | Meaning |
|---|---|
| `openspec/` | OpenSpec. Structured specs with requirements and scenarios — the highest-value source you can get |
| `docs/superpowers/plans/`, `docs/superpowers/specs/`, `docs/plans/` | Superpowers. Implementation plans and free-form design docs — no requirements exist in them |
| Anything else (wiki exports, `ARCHITECTURE.md`, ADRs) | Read it as evidence, weight it below the code |

Either of the first two → load `references/migrating.md` before going further. It carries the
exact source grammars, the mapping tables, and the traps that make a converted file fail
`pf-validate`.

Prior docs are a **source to read**, never a file to import. Do not copy a file across, do not
keep the two trees in sync, and do not delete the originals — the user decides that after
reviewing what you wrote.

Prior docs also age. Where a document and the code disagree, the code wins and the discrepancy
goes into `## Open Questions`.

## Step 3 — Survey the code

Read, in this order, and take notes as you go:

| Source | Tells you |
|---|---|
| Entrypoints — `main`, server bootstrap, CLI definitions | What the system is |
| Routes, handlers, public APIs | What callers can ask it to do |
| Data models, migrations, schemas | What it remembers |
| Background jobs, schedulers, queues | What it does unprompted |
| Configuration and feature flags | What varies per deployment |
| Existing tests | Behavior someone already considered worth protecting |

Migrating from OpenSpec: its specs tell you the intended behavior, so read code to confirm each
requirement still holds. Migrating from Superpowers: it has no requirements at all, so this step
is where the requirements actually come from.

## Step 4 — Propose the domains first

Present the domain list before creating any file: for each, the name, one line of what it covers,
and the code that led you to it.

```
- billing — hoá đơn, thanh toán, hoàn tiền (src/billing/**, migrations/004_invoices.sql)
- identity — đăng nhập, phiên, phân quyền (src/auth/**, middleware/session.ts)
```

Migrating from OpenSpec: its capability folders are usually flat (`cli-init`, `telemetry`) while
ProductFlow wants `<domain>/<capability>`. Propose the grouping here, with the capability list
that led to each domain, and let the user correct it.

Get the user's approval. Domain boundaries are the hardest thing to change later; a wrong split
propagates into every requirement ID.

## Step 5 — Write the approved domains

For each approved domain, create `docs/product/<domain>/PRD.md` from the template with
`status: draft`.

- Requirements describe behavior you **read in the code**, not behavior you expect the code to
  have. Allocate IDs with `../productflow/scripts/pf-reqid <domain> --count <n>`.
- Every requirement gets at least one scenario grounded in a real code path or a real test.
- `## Implementation Map` records the source file each requirement came from.
- One domain that clearly holds several independently testable capabilities: split it into
  capability sub-folders now, while nothing references it yet.
- Converting a prior document: keep its original wording where it is still true, and mint IDs
  with `pf-reqid` — neither OpenSpec nor Superpowers has requirement IDs to carry over.

## Step 6 — Record what you could not verify

Anything you could not confirm by reading goes into `## Open Questions`, phrased as a question.

Never turn an assumption into a requirement. A guessed requirement is worse than a missing one:
it looks verified, and the next change will be planned against it.

## Step 7 — Stop at three domains

Three domains per session, maximum. Then stop and ask the user to review what you wrote.

Onboarding accuracy falls off sharply as context fills, and a wrong PRD is harder to detect than
a missing one.

Before handing back:

```bash
../productflow/scripts/pf-index
../productflow/scripts/pf-validate
```

Fix every `error`. Report which domains are written, which remain, and every open question you
recorded. Converted from prior docs: also report which source files you used and which you
skipped, so the user can decide what to delete.
