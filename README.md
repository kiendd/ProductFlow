# ProductFlow

Agent skills for a single loop: **propose → plan → apply → archive**, with a PRD tree that
stays readable by both humans and machines.

## Install

```bash
git clone git@github.com:kiendd/ProductFlow.git ~/tools/productflow && cd ~/tools/productflow
./install.sh                              # symlinks into ~/.claude/skills
./install.sh --target ~/.agents/skills    # Codex / Copilot CLI / Gemini CLI
./install.sh --dry-run                    # preview only
```

Then, in the project you want to use it in:

```bash
~/.claude/skills/productflow/scripts/pf-init --locale vi
```

Requires `python3` (≥ 3.9), `git`, `bash`. Scripts use the standard library only.

Team-wide installs, existing `docs/` directories, migrating from OpenSpec or Superpowers,
name collisions, and troubleshooting: **[INSTALL.md](INSTALL.md)**.

## Skills

| Skill | Touch it when |
|---|---|
| `productflow` | Opening any conversation in a repo that uses ProductFlow — routes to the right skill |
| `propose` | A behavior change is requested and no change folder exists yet |
| `fix` | A bug is reported — fast lane: reproduce, fix, then check the PRD; a missing scenario, requirement, or PRD gets a short after-the-fact proposal that is archived in the same session |
| `plan` | A change has an approved proposal and delta but no `tasks.md` |
| `apply` | `tasks.md` still has unchecked tasks |
| `update` | A running change's artifacts need a **large** revision (no code edits) |
| `archive` | Every task is done and verified; merge the delta into the PRD tree |
| `prd` | Writing, editing, or validating any PRD document or delta |
| `onboard` | The repo has code but no `docs/product/` tree — including converting existing OpenSpec or Superpowers docs |

## Flow

```
propose  →  plan  →  apply  →  archive
   │                   │          │
   │                   └── update ┘   (revise artifacts mid-flight)
   ├── fix ────────────────────────┘   (bug: red test → fix → PRD gap? short proposal → archive)
   └── onboard first if docs/product/ does not exist (migrates OpenSpec / Superpowers docs)
```

## What it produces in a product repo

```
docs/product/            # source of truth, one PRD.md per domain/capability
  PRD.md  index.md  manifest.json   # index.md + manifest.json are generated
docs/changes/<slug>/     # change.md, requirements.md, tasks.md
docs/changes/archive/    # YYYY-MM-DD-<slug>/
.productflow/config.json # committed config
.productflow/runs/       # execution ledgers (gitignored)
```

## CLI

Six scripts live in `skills/productflow/scripts/` and find the repo root themselves:
`pf-init`, `pf-new-change`, `pf-reqid`, `pf-index`, `pf-validate`, `pf-archive`.
Full contract and exit codes: `skills/productflow/references/cli.md`.

## Tests

```bash
bash tests/run.sh   # end-to-end against a temporary sandbox repo
```
