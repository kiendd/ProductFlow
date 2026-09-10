---
name: prd
description: Use when writing, editing, merging, or validating any PRD document or delta requirement in the product docs tree.
---

# Writing PRDs

This skill is the format authority. Every other ProductFlow skill defers to it.

Load `references/prd-format.md` before writing a document for the first time in a session, or
whenever you are unsure about a field. Load `references/writing-style.md` before writing prose.

## Language

Prose — summaries, statements, scenario names, questions — is written in the language named by
`prd_locale` in `.productflow/config.json` (default `vi`).

Structure is always English and never translated: frontmatter keys, the ten `## ` headings,
`**Status**`, `**Statement**`, `**Target**`, `**Reason**`, `**Migration**`, `**FROM**`, `**TO**`,
`#### Scenario:`, `**WHEN**`, `**THEN**`, `ADDED`/`MODIFIED`/`REMOVED`/`RENAMED`, and requirement IDs.

## Document skeleton

Frontmatter keys `id`, `title`, `type`, `domain`, `status`, `updated` are mandatory; `parent`,
`owner`, `source_changes`, `implements` are used when they apply. Then exactly these ten `## `
sections, in this order, none omitted even when empty:

`Summary` · `Problem & Goals` · `Users & Use Cases` · `Requirements` · `Behavior Details` ·
`Interfaces & Data` · `Out of Scope` · `Implementation Map` · `Open Questions` · `Change Log`

A requirement is:

```markdown
### REQ-BILLING-001: <title>
**Status**: active
**Statement**: <one sentence with PHẢI / MUST>

#### Scenario: <name>
- **WHEN** <trigger>
- **THEN** <observable result>
```

Requirements sit in `## Requirements` in ascending ID order.

## Requirement IDs

`REQ-<PREFIX>-<NNN>`, where `<PREFIX>` is the first domain segment uppercased. Allocate with
`../productflow/scripts/pf-reqid <domain> --count N`. Never invent a number, never reuse a
retired one, never renumber an existing requirement.

## What belongs in a PRD

**Observable behavior only**: what the system does, for whom, under which conditions, and what
the user sees. A reader who cannot see the code must be able to test every requirement.

**Never in a PRD**: class names, function names, library choices, file layout, algorithms.
Those belong in the change's `## Design` section while a change runs, and in
`## Implementation Map` as bare paths afterwards.

## Splitting the tree

One capability equals one group of behavior that can be tested independently. Split a PRD into
a sub-folder when it passes roughly 400 lines or 12 requirements. Nest at most one extra level
below capability; deeper than that means the domain boundary is wrong.

| Level | `type` | Example path |
|---|---|---|
| Whole system | `product` | `docs/product/PRD.md` |
| Domain | `domain` | `docs/product/billing/PRD.md` |
| Capability | `capability` | `docs/product/billing/invoicing/PRD.md` |

`id` is always derived from the path — never chosen by hand.

## Deltas

Change folders never edit PRDs directly. They record a delta in `requirements.md` with all four
buckets present: `ADDED`, `MODIFIED`, `REMOVED`, `RENAMED`. `MODIFIED` restates the complete new
requirement, not the diff. `productflow:archive` merges the delta into the tree.

## Before you hand back

1. Every touched PRD has `updated` set to today and a new `## Change Log` row.
2. Every requirement has at least one scenario, and every scenario has `**WHEN**` and `**THEN**`.
3. `## Implementation Map` lists real, existing paths — no placeholders.
4. `../productflow/scripts/pf-index` then `../productflow/scripts/pf-validate` exit 0.

A finding you cannot explain means the document is wrong, not the validator.
