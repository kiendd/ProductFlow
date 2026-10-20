---
id: product.workflow
title: Skills and change lifecycle
type: domain
domain: workflow
parent: product
status: draft
owner: unassigned
updated: 2026-10-20
source_changes: []
implements: [skills/productflow/SKILL.md, skills/brainstorm/SKILL.md, skills/propose/SKILL.md, skills/plan/SKILL.md, skills/apply/SKILL.md, skills/archive/SKILL.md, skills/fix/SKILL.md, skills/update/SKILL.md, skills/onboard/SKILL.md, skills/prd/SKILL.md]
---

# Skills and change lifecycle

## Summary

Workflow is the set of skills that route a request and carry a change from idea to archive. A router
skill reads the index and dispatches to one of ten skills by repository state. The lifecycle skills
enforce one invariant: no behavior reaches code before it is written as a requirement, and no
requirement is archived before a test proves it.

## Problem & Goals

An agent left to its own judgement edits code first and documents later, if ever. The goal is a set
of skills whose own rules make skipping the documentation step the harder path, not the easier one.

## Users & Use Cases

- An agent opening a conversation in a ProductFlow repository, deciding which skill to run.
- A developer requesting a feature, a bugfix, or a mid-flight revision and relying on the skill to
  take the correct lane.

## Requirements

### REQ-WORKFLOW-001: Route by repository state
**Status**: active
**Statement**: The `productflow` router MUST read `docs/product/index.md` first, then route to the
skill matching the repository state before answering, exploring, or editing.

#### Scenario: No docs tree routes to onboard
- **WHEN** the router runs in a repository with no `docs/product/` tree
- **THEN** it routes to `productflow:onboard`

#### Scenario: Unchecked tasks route to apply
- **WHEN** the router runs where a change's `tasks.md` still has `- [ ]` boxes
- **THEN** it routes to `productflow:apply`

### REQ-WORKFLOW-002: Behavior changes go through the loop
**Status**: active
**Statement**: A requested behavior change MUST pass through propose, plan, apply, and archive, and
no code MUST be written before the user approves the written proposal.

#### Scenario: A proposal gates the code
- **WHEN** a user requests a behavior change
- **THEN** `productflow:propose` classifies it and writes a change folder, and implementation does
  not begin until the user approves it

### REQ-WORKFLOW-003: Brainstorm explores before proposing
**Status**: active
**Statement**: When a feature is still fuzzy, `productflow:brainstorm` MUST explore the design space
in rounds without writing any change folder, and MUST hand off to `productflow:propose` once the
design is settled and agreed.

#### Scenario: A fuzzy idea is shaped then handed off
- **WHEN** a user brings an idea that is not yet concrete enough to classify
- **THEN** `brainstorm` works the open decisions in rounds and, once settled, hands off to
  `productflow:propose` without having created a change folder itself

### REQ-WORKFLOW-004: Bugs take the fast lane
**Status**: active
**Statement**: A bug where the intended behavior does not move MUST go through `productflow:fix` —
reproduce, fix, then check the PRD — and MUST escalate to `productflow:propose` the moment the
intended behavior itself changes.

#### Scenario: A bug is fixed and the PRD gap is closed
- **WHEN** code violates a behavior a requirement already states
- **THEN** `fix` reproduces it with a failing test, makes it pass, and opens a short after-the-fact
  proposal when the PRD was missing the scenario or requirement

### REQ-WORKFLOW-005: Mid-flight revisions go through update
**Status**: active
**Statement**: A large revision to a running change's artifacts MUST go through
`productflow:update`, which edits only the change's documents and never the code, and MUST present
every edit to the user before writing it.

#### Scenario: A new requirement mid-flight routes to update
- **WHEN** a running change needs a requirement that no existing statement covers
- **THEN** the work routes to `productflow:update`, which revises the artifacts after the user agrees
  and hands back to `productflow:apply`

## Behavior Details

Direct user instructions and `AGENTS.md` / `CLAUDE.md` override the router. The loop is
brainstorm → propose → plan → apply → archive, with `fix` as a bug lane, `update` for mid-flight
revisions, and `onboard` to build the first tree.

## Interfaces & Data

- Router: `skills/productflow/SKILL.md`, reading `docs/product/index.md`.
- Lifecycle skills: `brainstorm`, `propose`, `plan`, `apply`, `archive`, `fix`, `update`, `onboard`,
  and `prd` as the format authority.

## Out of Scope

- The document format each skill defers to — see the authoring domain.
- The scripts the skills call — see the cli domain.

## Implementation Map

| Requirement | Code | Tests |
|---|---|---|
| REQ-WORKFLOW-001 | `skills/productflow/SKILL.md` | — |
| REQ-WORKFLOW-002 | `skills/propose/SKILL.md` | — |
| REQ-WORKFLOW-003 | `skills/brainstorm/SKILL.md` | — |
| REQ-WORKFLOW-004 | `skills/fix/SKILL.md` | — |
| REQ-WORKFLOW-005 | `skills/update/SKILL.md` | — |

## Open Questions

- The workflow domain's behavior lives in SKILL.md prose; there is no automated test that a skill
  routes as specified. Should routing be exercised by a harness test?

## Change Log

| Date | Change | Summary |
|---|---|---|
| 2026-10-20 | onboard | Drafted REQ-WORKFLOW-001..005 from the skill files, including the new brainstorm skill |
