# Migrating from OpenSpec and Superpowers

Exact source formats and their ProductFlow targets. Read the section for the tool you found.

ProductFlow **replaces** these tools. You read their files as a source, rewrite the content into
the PRD tree, and stop there. Never import a file unchanged, never keep the two trees in sync,
and never delete the originals — that is the user's call, made after they have reviewed what you
wrote.

---

## OpenSpec

### Detecting it

An `openspec/` directory at the repo root. Confirm with `openspec/specs/` or `openspec/changes/`.

```
openspec/
  config.yaml                        # schema, context, rules   (current)
  project.md                         # project context          (legacy, still common)
  specs/<capability-path>/spec.md    # merged truth — the valuable part
  changes/<slug>/
    .openspec.yaml                   # schema, created, skip_specs, affected_areas
    proposal.md
    design.md                        # optional
    tasks.md
    specs/<capability-path>/spec.md  # delta, one file PER capability
  changes/archive/YYYY-MM-DD-<slug>/ # same shape
  explorations/*.md                  # free-form
  initiatives/<id>/                  # planning layer above changes
```

The filename is always `spec.md` inside a capability folder. A capability path may be nested
(`identity/user-auth`).

### Spec format

No frontmatter anywhere. Two meaningful H2s: `## Purpose` and `## Requirements`.

```markdown
# telemetry Specification

## Purpose
<one prose blob>

## Requirements

### Requirement: Command execution tracking
The system SHALL send a `command_executed` event to PostHog when any CLI command executes.

#### Scenario: Standard command execution
- **WHEN** a user runs any openspec command
- **THEN** the system sends a `command_executed` event with `command` and `version` properties
```

Delta files under a change use exactly the four buckets ProductFlow uses —
`## ADDED Requirements`, `## MODIFIED Requirements`, `## REMOVED Requirements`,
`## RENAMED Requirements` — but OpenSpec omits empty buckets and matches them case-insensitively.

### The five things that will bite you

**1. OpenSpec requirements have no IDs.** The heading text *is* the identity. You must mint every
ID with `../../productflow/scripts/pf-reqid <domain> --count <n>`. This is one-way: nothing in the
OpenSpec history can be traced back to a minted ID. Record the original heading text as the
requirement title so a human can still match them by eye.

**2. Only two of the ten PRD sections have a source.** `## Purpose` becomes `## Summary`;
`## Requirements` maps across. The other eight have no OpenSpec equivalent. Write what the code
tells you, and put the rest in `## Open Questions`. Never invent content to fill a section —
leave the heading with an explicit note that it was not covered by the source.

**3. Capability names are usually flat.** OpenSpec projects commonly have single-segment
capabilities (`cli-init`, `telemetry`, `cli-feedback`) where ProductFlow wants
`<domain>/<capability>`. Grouping them into domains is a judgment call, and it is exactly the
decision to put in front of the user in Step 4 of the skill. Nested OpenSpec paths map 1:1.

**4. OpenSpec's grammar is looser than ProductFlow's.** Files that pass OpenSpec validation will
fail `pf-validate`:

| OpenSpec tolerates | ProductFlow requires |
|---|---|
| Any `#### ` heading counts as a scenario | The literal `#### Scenario: <name>` prefix |
| A scenario with only `**THEN**`, or with `**GIVEN**` / `**AND**` | At least one `**WHEN**` bullet and one `**THEN**` bullet |
| Case-insensitive bucket headings, empty buckets omitted | Exact casing, all four buckets present |
| A missing `SHALL` / `MUST` (warning only) | A statement carrying one modal |
| Multi-paragraph requirement bodies | One-sentence `**Statement**:`; the rest goes to `## Behavior Details` |

`**GIVEN**` has no ProductFlow slot — fold its content into the `**WHEN**` bullet.

**5. `TBD - created by archiving change …`** is OpenSpec's generated placeholder for an unwritten
Purpose. Treat it as absent, not as content.

### Mapping

| OpenSpec | ProductFlow | Fidelity |
|---|---|---|
| `specs/<cap>/spec.md` | `docs/product/<domain>/<cap>/PRD.md` | Direct, once the domain is chosen |
| Spec H1 `# <name> Specification` | frontmatter `title` + H1 — strip `" Specification"` | Direct |
| `## Purpose` | `## Summary` | Direct |
| `### Requirement: <name>` | `### REQ-<PREFIX>-<NNN>: <name>` | ID minted, title kept |
| Requirement body (first sentence) | `**Statement**:` | Rest → `## Behavior Details` |
| (nothing) | `**Status**:` | Default `active` |
| `#### Scenario:` + WHEN/THEN | Same | Near-lossless; fix the exceptions above |
| (nothing) | frontmatter, `## Implementation Map` | Synthesized — fill from the code, not from OpenSpec |
| `changes/<slug>/proposal.md` | `change.md` (`## Why`, `## What Changes`, `## Scope`, `## Impact`) | `## Capabilities` → frontmatter `domains:`; `## Non-goals` → `### Out of scope` |
| `changes/<slug>/specs/**/spec.md` (N files) | `requirements.md` (one file) | Collapse N files into one; capability id becomes each entry's `**Target**:` |
| `changes/<slug>/tasks.md` | `tasks.md` | Heavily lossy — see below |
| `design.md` | `design.md` | `Risks / Trade-offs` → `Risks & Trade-offs`; `Migration Plan` → `Migration`; `Goals / Non-Goals` has no target |
| `.openspec.yaml` `affected_areas` | frontmatter `domains:` | Lossy guess |
| `config.yaml` `context`, `rules` | Nothing | Belongs in `AGENTS.md`, not in a PRD |
| `project.md` (legacy) | Nothing directly | Source material for `docs/product/PRD.md` |
| `explorations/`, `initiatives/`, `work/` | Nothing | No ProductFlow layer above a change |

**`tasks.md` cannot be converted mechanically.** OpenSpec tasks are single lines
(`- [ ] 1.1 <description>`); ProductFlow requires ` — verify: <command>` plus the three child
lines `Requirements:`, `Files:`, `Steps:`. None of that exists in the source. Indented sub-tasks
(`1.1.1`) are also dropped by ProductFlow's two-level grammar. Do not fabricate verify commands.

### Which changes to convert

| Change state | Action |
|---|---|
| Archived (`changes/archive/**`) | **Do not convert.** Its requirements already live in `openspec/specs/`, which you are converting. Converting both duplicates every requirement |
| In flight, tasks unfinished | Convert to `docs/changes/<slug>/`, then continue it under `productflow:plan` or `productflow:apply` |
| In flight, code done but not archived | Convert, then run `productflow:archive` to merge it properly |

Archived changes are worth reading for one thing only: reconstructing a `## Change Log`. That is
expensive and optional — say so rather than silently skipping it.

### Legacy variants

| Legacy | Current |
|---|---|
| `openspec/project.md` | `openspec/config.yaml` → `context:` |
| `openspec/AGENTS.md`, root marker blocks | Generated skills |
| Deltas as bullets in `## What Changes`: `- **<spec>:** adds X` | Delta files under `changes/<slug>/specs/` |
| Flat capabilities only | Nested capability paths |

A repo may hold either form. The bullet form carries far less detail — a verb and a sentence, no
scenarios — so a requirement derived from it is a stub, and belongs in `## Open Questions` until
someone confirms it.

Prose may be non-English while the grammar stays English. Keep the prose language unless the user
asks otherwise, and match `prd_locale`.

---

## Superpowers

### Detecting it

`docs/superpowers/plans/` or `docs/superpowers/specs/`, or the older `docs/plans/`. Both paths
are user-overridable, so also sniff file contents for the marker line
`> **For agentic workers:**`.

### What is actually there

**Two durable artifacts, and only for the architectural path.** Superpowers' bounded and spike
paths deliberately write no files, so whatever you find systematically under-represents the work
that was actually done.

| Artifact | Path | Structure |
|---|---|---|
| Implementation plan | `docs/superpowers/plans/YYYY-MM-DD-<slug>.md` | Fully templated, parseable |
| Design doc | `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` | **No template** — free prose |

Anything under `.superpowers/` is git-ignored scratch that the tool deletes when a run finishes.
Ignore it. The execution ledger and its `Ruling:` lines are gone; they are not recoverable.

### Plan format

No frontmatter. Fixed heading grammar:

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence describing what this builds]
**Architecture:** [2-3 sentences about approach]
**Tech Stack:** [Key technologies/libraries]
**Spec:** [path to the design doc this plan implements]

## Global Constraints

## File Structure

### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Test: `tests/exact/path/to/test.py`

**Interfaces:**
- Consumes: [signatures from earlier tasks]
- Produces: [what later tasks rely on]

- [ ] **Step 1: Write the failing test**
```

Only steps are checkboxes; tasks are not. Checkbox state is unreliable — real progress lived in
the deleted ledger, so trust `git log` instead.

### The honest assessment

**Superpowers has no requirement construct.** No requirements, no acceptance criteria, no
given/when/then. This is not an omission in the research; the construct does not exist.

That means:

- A plan is an **implementation plan, not a specification**. It records what was built, in what
  order, touching which files, under which constraints.
- Producing a requirement from it means reading the embedded test code and the design prose and
  **writing a requirement that never previously existed**. That is authorship.
- Every such requirement is a guess about intent until a human confirms it.

So: use Superpowers artifacts to reconstruct *what the system does* — then verify each claim
against the code before writing it as a requirement, exactly as you would with no prior docs at
all. Tell the user plainly that these requirements were derived, not migrated.

### Mapping

| Superpowers | ProductFlow | Fidelity |
|---|---|---|
| Plan `**Goal:**` + `**Architecture:**` | Input to `## Summary` | Plan-scoped, not product-scoped |
| `## Global Constraints` | `## Interfaces & Data`, or `## Behavior Details` | One constraint per bullet, mechanical |
| `## File Structure`, per-task `**Files:**` | `## Implementation Map` | Mechanical, high value — verify the paths still exist |
| `**Spec:**` field | Link to the design doc | Mechanical |
| Design doc prose | `## Problem & Goals`, `## Behavior Details`, `## Out of Scope` | Needs an agent to read and restructure |
| `### Task N:` + steps | Nothing in a PRD | Tasks are execution history, not product docs |
| Requirements, scenarios | **Nothing** | Must be authored from code, then verified |
| Personas, metrics, ownership, status | **Nothing** | No source |
| `.superpowers/` ledger, rulings | **Nothing** | Deleted by the tool; unrecoverable |

An unfinished plan — steps unchecked and the work genuinely incomplete — is not documentation.
Offer to turn it into a ProductFlow change with `productflow:propose` instead of forcing it into
a PRD.

---

## Before you finish

1. Every migrated requirement traces to code you actually read. A requirement copied from a spec
   whose implementation you never found goes in `## Open Questions`, not `## Requirements`.
2. `status: draft` on every PRD produced this way. It is a reading of prior docs, not an agreed
   specification.
3. Report which source files you used and which you skipped, so the user can decide what to
   delete.
4. `../../productflow/scripts/pf-index` then `../../productflow/scripts/pf-validate`, both clean.
