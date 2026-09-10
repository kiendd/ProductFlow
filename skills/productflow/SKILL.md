---
name: productflow
description: Use when starting any conversation in a repository that uses ProductFlow, before answering, exploring, or editing anything.
---

# ProductFlow

Read `docs/product/index.md` first. Then route:

| State | Skill |
|---|---|
| No `docs/product/` yet, or `openspec/` / `docs/superpowers/` to convert | `productflow:onboard` |
| Behavior change requested, no change folder | `productflow:propose` |
| Change has delta, no `tasks.md` | `productflow:plan` |
| `tasks.md` has `- [ ]` | `productflow:apply` |
| Running change needs a **large** artifact revision | `productflow:update` |
| All tasks done and verified | `productflow:archive` |
| Question about document format | `productflow:prd` |

## Rules

Announce the skill and follow it before answering, exploring, or editing. Docs are the source of truth.

Direct user instructions and `AGENTS.md` / `CLAUDE.md` override this skill.

## Red flags

Stop if you think any of these:

| Thought | Reality |
|---|---|
| "Simple question, no skill needed" | The index answers it faster |
| "Let me look at the code first" | The docs say what the code should do |
| "Too small for a change folder" | `propose` classifies size; you do not |
| "I will document it afterwards" | Undocumented work cannot be archived |

CLI commands and exit codes: `references/cli.md` — load only when running a script.
