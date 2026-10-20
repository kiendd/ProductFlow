---
id: product
title: ProductFlow
type: product
domain: product
status: draft
owner: unassigned
updated: 2026-10-20
source_changes: []
implements: []
---

# ProductFlow

## Summary

ProductFlow is a set of agent skills and a small CLI that keep a repository's product
documentation in sync with its code. It runs one loop — brainstorm, propose, plan, apply,
archive — and stores every requirement in a PRD tree that both humans and machines can read.
It ships as skill directories plus six Python scripts that have no third-party dependencies.

## Problem & Goals

Agents edit code faster than documentation can keep up, so the two drift apart. ProductFlow's
goal is that no behavior change reaches code before it is written as a requirement, and no
requirement is archived before a test proves it.

- **Goal**: every behavior change is recorded as a requirement with at least one testable scenario.
- **Goal**: the PRD tree validates mechanically, so drift is caught by a script, not by review.
- **Goal**: the loop works the same whether the harness can dispatch subagents or not.

## Users & Use Cases

- **A developer** adopting ProductFlow in an existing repository: runs `onboard` to build the
  first PRD tree, then uses the loop for every later change.
- **A coding agent** working inside a ProductFlow repository: reads the index, routes to the
  correct skill, and never edits code outside the loop.

## Requirements

<!-- Requirements live in the domain PRDs: cli, authoring, workflow. -->

## Behavior Details

The system has three domains:

- **cli** — the six `pf-*` executables that scaffold, allocate IDs, index, validate, and archive.
- **authoring** — the document format for PRDs, deltas, and task lists, and the rules the
  validator enforces.
- **workflow** — the skills that route a request and carry a change through its lifecycle.

## Interfaces & Data

- **CLI**: `pf-init`, `pf-new-change`, `pf-reqid`, `pf-index`, `pf-validate`, `pf-archive`.
- **Config**: `.productflow/config.json` holds `docs_root`, `changes_root`, `prd_locale`,
  `requirement_prefix`.
- **Generated data**: `docs/product/index.md` and `docs/product/manifest.json`.

## Out of Scope

- Running tests, building, or deploying the product repository.
- Any language runtime other than Python 3.9+ for the scripts.

## Implementation Map

| Requirement | Code | Tests |
|---|---|---|

## Open Questions

- Should the skills' own routing behavior be covered by an automated test, or is the SKILL.md
  prose the only source of truth for the workflow domain?

## Change Log

| Date | Change | Summary |
|---|---|---|
| 2026-10-20 | onboard | Initial PRD tree drafted from the skills and CLI scripts |
