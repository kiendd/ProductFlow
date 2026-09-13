---
name: propose
description: Use when feature work or a behavior change is requested and no change folder exists yet — before any implementation. Bugs where the intended behavior does not move go to productflow:fix instead.
---

# Proposing a change

Turn a request into a classified, agreed, written proposal. Nothing is built here.

## Hard gate

Before you write a line of code, scaffold a file, or hand off to another skill:

1. State what you understood the request to be.
2. State the classification and why.
3. Get explicit agreement from the user.

Exploratory reading of the repository is allowed. Writing is not, apart from the change folder
itself once the classification is agreed.

## Step 1 — Read the ground first

Read `docs/product/index.md` and list the domains the request touches. Then open only those
domain `PRD.md` files to quote the real requirement IDs back to the user.

No `docs/product/` tree exists → stop and run `productflow:onboard` first. A proposal written
against an unmapped codebase is guesswork.

## Step 2 — Classify out loud

Announce the branch before your first question so the user can overrule it.

| Branch | Fits when | Produces |
|---|---|---|
| **Spike** | The answer is unknown and must be learned by trying | No files. A written recommendation, and any throwaway code clearly labelled as throwaway |
| **Bounded** | Behavior is clear, one domain, no new architecture | `change.md` + `requirements.md` |
| **Architectural** | Two or more modules, a new dependency, a data-model change, or a security/performance/migration constraint | `change.md` + `requirements.md`; `productflow:plan` fills the `## Design` section of `change.md` |

When unsure, take the heavier branch. If complexity surfaces mid-conversation, escalate the
branch — never downgrade it.

### Red flags

| Thought | Reality |
|---|---|
| "This is a one-line fix" | A one-line fix that changes behavior still changes a requirement |
| "I already know the design" | Then writing it costs a minute and the user can disagree |
| "Bugfix, so no requirement changes" | If the fix changes observable behavior, the requirement was wrong; fix it too. If the requirement is right and the code is wrong, this is `productflow:fix`, not a proposal |
| "Spike, so no docs needed" | A spike still ends in a written recommendation |
| "The user is in a hurry" | Then a wrong branch costs them more than the proposal does |

## Step 3 — Ask in batched turns

Group related questions into one turn instead of one per message. Prefer multiple choice with a
recommended option. Keep each turn focused — a few related questions, not every open question at
once.

Cover, in this order: the problem behind the request, who is affected, observable behavior
expected, edge cases and failure behavior, explicit non-goals.

Then present two or three options with their trade-offs and name your recommendation. Present
design one section at a time and ask for confirmation after each.

Stop asking when you can write every requirement statement without inventing anything. Anything
still unknown goes into `## Open Questions`, never into a guessed requirement.

## Step 4 — Write the outputs

**Spike**: no change folder. Report findings, the recommendation, and what to propose next.
Label every experimental file as throwaway and delete it before finishing.

**Bounded**:

```bash
../productflow/scripts/pf-new-change <slug>
```

**Architectural**:

```bash
../productflow/scripts/pf-new-change <slug> --classification architectural
```

Then fill in `change.md` (`## Why`, `## What Changes`, `## Scope` with in/out lists, `## Impact`)
and `requirements.md`. Set `domains:` in the frontmatter. Follow `productflow:prd` for every
format decision and for the writing language.

Allocate IDs while writing the delta, so tasks and tests can reference stable IDs:

```bash
../productflow/scripts/pf-reqid <domain> --count <n>
```

The `## Design` section of `change.md` belongs to `productflow:plan`; leave it empty for that skill.

## Step 5 — Close

1. Run `../productflow/scripts/pf-validate` and fix every `error` finding.
2. Summarize what you wrote: the change slug, each requirement ID with its one-line statement,
   and what is explicitly out of scope. Architectural changes: ask the user to read the files.
3. **Ask for approval and stop.** Wait for a reply that approves the written proposal.
4. Only then hand off to `productflow:plan`.

Silence is not approval, and neither is the absence of an objection. The user has to say yes to
what you wrote — not to the classification you announced back in Step 2, which is a different
question. Writing the change folder and handing off in the same turn skips this gate.
