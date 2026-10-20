---
name: brainstorm
description: Use when a new feature or idea is still fuzzy and must be explored before it can be proposed — map the design space in rounds, pressure-test it, settle every open decision, then hand to productflow:propose to write the change. A concrete, agreed request goes straight to productflow:propose.
---

# Brainstorming a feature

Shape a fuzzy idea into a settled design the user agrees with, then hand it to `productflow:propose`
to classify and write. Nothing is built here, and no change folder is created — brainstorm produces
a shared understanding, not a document.

Format questions go to `productflow:prd`.

## When this skill, not another

| Situation | Skill |
|---|---|
| The feature is fuzzy, or a direction needs pressure-testing before it is written | **brainstorm** (here) |
| The behavior is already clear and agreed; it only needs classifying and writing | `productflow:propose` |
| A bug: the code violates behavior a requirement already states | `productflow:fix` |

## Step 1 — Read the ground first

Read `docs/product/index.md`, then open the domain `PRD.md` files the idea touches. Quote the real
requirement IDs the idea would extend or collide with. The design space is bounded by what already
exists; discover that boundary before asking the user anything.

No `docs/product/` tree → run `productflow:onboard` first. Brainstorming against an unmapped
codebase invents constraints that are not real.

Exploratory reading is allowed. Writing is not — not code, not a change folder, not a requirement.

## Step 2 — Map the design as a tree

Hold the idea as a **design tree**: the root is the feature; each node is one decision; a child
depends on its parent being settled. Every decision branches into the decisions that hang off it.

## Step 3 — Work the frontier in rounds

The **frontier** is every decision whose prerequisites are already settled — the questions you can
ask *now* without guessing answers you have not heard yet. Ask the whole frontier in one round.
Number each question and give your recommended answer.

```
❓ **Q1** — **<title>**: <body, with the options when there is a choice>
➡️ <your recommended answer>

---

❓ **Q2** — **<title>**: <body>
➡️ <your recommended answer>
```

Word each question so "yes" accepts your recommendation. Then wait for the user's answers before the
next round. Across the rounds, cover in roughly this order: the problem behind the idea, who is
affected, the observable behavior wanted, edge cases and failure behavior, and the explicit
non-goals.

## Step 4 — Recompute the frontier after every round

Each answer reshapes the tree. Settled decisions push the frontier outward and unblock the questions
that depended on them. Recompute the frontier and ask the next round. A question whose answer depends
on another still open in this round belongs to a *later* round, never this one.

## Step 5 — Find facts yourself

Finding *facts* is your job, never the user's. A frontier question that needs a fact from the
repository — does this module exist, what does this endpoint return — you look up, or dispatch a
sub-agent to find. Do not block the whole round on it: a running exploration is an unsettled
prerequisite, so only the questions downstream of that fact wait; ask the rest of the frontier now.
The *decisions* are the user's: put each to them and wait.

## Step 6 — Pressure-test, then close

Before the frontier counts as empty, attack the settled design once: name the assumption most
likely to be wrong, the user it serves worst, and the cheapest alternative you rejected. A branch
that does not survive the attack reopens as a new frontier question. When nothing breaks:

1. Summarize the settled design: the problem, the observable behavior, the edge cases decided, and
   the explicit non-goals.
2. List anything still genuinely unknown as an open question — never as a settled decision.
3. Confirm the shared understanding with the user, and wait for them to agree.
4. Hand off to `productflow:propose`. It classifies the change (spike / bounded / architectural),
   writes the change folder and the requirements delta, and runs its own approval gate before any
   code.

Do not create a change folder here, and do not write requirements. Brainstorm settles the design;
`propose` records it.

## Red flags

| Thought | Reality |
|---|---|
| "The idea is clear enough, skip to code" | No code is written here; a clear idea goes to `propose`, not the editor |
| "I will ask every open question at once" | A question that depends on an unsettled answer is a guess; ask only the frontier |
| "Let the user find that fact" | Facts are your job; ask the user only for decisions |
| "We are agreed, I will write the change folder" | Writing the change folder is `propose`'s gate, not brainstorm's |
| "This is just a small idea, no need to propose" | `propose` classifies size; brainstorm only decides whether the design is settled |
