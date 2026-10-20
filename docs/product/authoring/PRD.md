---
id: product.authoring
title: Document format and validation
type: domain
domain: authoring
parent: product
status: draft
owner: unassigned
updated: 2026-10-20
source_changes: []
implements: [skills/productflow/scripts/_pflib.py, skills/prd/references/prd-format.md]
---

# Document format and validation

## Summary

Authoring defines the shape of every document in the tree — the PRD, the change delta, and the task
list — and the rules `pf-validate` enforces against them. The format is a strict subset parsed by
regex, not by a general markdown or YAML parser, so every rule has a named finding code and the tree
either validates or it does not.

## Problem & Goals

Documents that both humans and scripts read must be machine-checkable, or drift creeps back in
through formatting. The goal is that a structural mistake produces a specific finding code with a
known fix, never a silent pass.

## Users & Use Cases

- An agent writing a PRD or delta who needs the structure to pass validation on the first hand-back.
- A reviewer reading a finding code and applying the documented fix from `references/cli.md`.

## Requirements

### REQ-AUTHORING-001: Canonical PRD sections
**Status**: active
**Statement**: A PRD MUST contain the ten `##` sections — Summary, Problem & Goals, Users & Use
Cases, Requirements, Behavior Details, Interfaces & Data, Out of Scope, Implementation Map, Open
Questions, Change Log — in that order, none omitted even when empty.

#### Scenario: A missing or reordered section is flagged
- **WHEN** `pf-validate` runs against a PRD that omits a section or has them out of order
- **THEN** it exits 1 and reports `section-missing` or `section-order`

### REQ-AUTHORING-002: Requirement and scenario shape
**Status**: active
**Statement**: Each requirement MUST have a heading matching `### REQ-<PREFIX>-<NNN>: <title>`
followed by `**Status**:` and `**Statement**:`, and at least one `#### Scenario:` that carries a
`**WHEN**` bullet and a `**THEN**` bullet.

#### Scenario: A scenario missing WHEN or THEN is flagged
- **WHEN** `pf-validate` runs against a PRD whose scenario lost its `**THEN**` bullet
- **THEN** it exits 1 and reports `scenario-no-when-then`

### REQ-AUTHORING-003: Unique, derived requirement IDs
**Status**: active
**Statement**: A requirement ID MUST be `REQ-<PREFIX>-<NNN>` where `<PREFIX>` is the first domain
segment uppercased, MUST be unique across the whole `docs/product` tree, and a retired ID MUST never
be reused.

#### Scenario: A duplicate ID is flagged
- **WHEN** `pf-validate` runs against a tree where the same `REQ-` ID appears in two PRDs
- **THEN** it exits 1 and reports `req-duplicate`

### REQ-AUTHORING-004: Complete change delta
**Status**: active
**Statement**: A change's `requirements.md` MUST contain all four buckets — ADDED, MODIFIED,
REMOVED, RENAMED — where ADDED and MODIFIED each carry `**Target**`, MODIFIED restates the whole
requirement rather than a diff, and REMOVED carries `**Reason**` and `**Migration**`.

#### Scenario: An ADDED entry without a target is flagged
- **WHEN** `pf-validate` runs against a delta whose ADDED entry has no `**Target**`
- **THEN** it exits 1 and reports `delta-missing-target`

#### Scenario: A partial MODIFIED entry is flagged
- **WHEN** `pf-validate` runs against a delta whose MODIFIED entry omits an existing scenario
- **THEN** it exits 1 and reports `delta-modified-incomplete`

### REQ-AUTHORING-005: Prose language follows the configured locale
**Status**: active
**Statement**: Prose — summaries, statements, scenario names, questions — MUST be written in the
language named by `prd_locale`, while structure — frontmatter keys, the ten section headings,
`**WHEN**`, `**THEN**`, bucket names, and requirement IDs — MUST stay English and untranslated.

#### Scenario: Structure stays English under a non-English locale
- **WHEN** a repository is initialized with `--locale vi` and a PRD is written
- **THEN** the section headings and `**WHEN**` / `**THEN**` markers remain English while the
  summaries and statements are in Vietnamese

## Behavior Details

Frontmatter is a strict `key: value` subset: no nesting, no multiline values, no comments, no blank
lines, no duplicate keys. Each rule maps to a finding code listed in `references/cli.md`; the fix is
to correct the document, never to silence the check.

## Interfaces & Data

- Format specification: `skills/prd/references/prd-format.md`.
- Finding codes and fixes: `skills/productflow/references/cli.md`.
- Validator: `pf-validate` in the cli domain.

## Out of Scope

- The commands that run the validator and generate the index — see the cli domain.
- Which skill writes which document — see the workflow domain.

## Implementation Map

| Requirement | Code | Tests |
|---|---|---|
| REQ-AUTHORING-001 | `skills/productflow/scripts/_pflib.py` | — |
| REQ-AUTHORING-002 | `skills/productflow/scripts/_pflib.py` | `tests/run.sh` |
| REQ-AUTHORING-003 | `skills/productflow/scripts/_pflib.py` | — |
| REQ-AUTHORING-004 | `skills/productflow/scripts/_pflib.py` | — |
| REQ-AUTHORING-005 | `skills/productflow/scripts/_pflib.py` | — |

## Open Questions

- Only `scenario-no-when-then` is exercised by `tests/run.sh`; the other finding codes are covered
  by code but have no regression test.

## Change Log

| Date | Change | Summary |
|---|---|---|
| 2026-10-20 | onboard | Drafted REQ-AUTHORING-001..005 from `prd-format.md` and the validator |
