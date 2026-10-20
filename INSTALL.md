# Installing and integrating ProductFlow

How to install the skills, and how to adopt them in a project that already exists.

Every command below has been run against a real repository; the outputs quoted are real.

## Requirements

| Need | Why | Check |
|---|---|---|
| `python3` ≥ 3.9 | The six CLI scripts | `python3 --version` |
| `git` | Change branches, archive history | `git --version` |
| `bash` | `install.sh`, `tests/run.sh` | `bash --version` |

No packages to install. The scripts use the Python standard library only.

---

## Part 1 — Install the skills

Pick one of three modes. They differ in who gets the skills and how updates arrive.

| Mode | Skills available in | Team gets them | Updating |
|---|---|---|---|
| **A. Personal symlink** | Every project you open | No | `git pull` in the clone |
| **B. Vendored into the project** | That one repository | Yes, on clone | Copy again, or use C |
| **C. Submodule + symlink** | That one repository | Yes, on clone | `git submodule update` |

### A. Personal install (start here)

```bash
git clone git@github.com:kiendd/ProductFlow.git ~/tools/productflow
cd ~/tools/productflow
./install.sh
```

Real output:

```
linked /Users/you/.claude/skills/apply -> /Users/you/tools/productflow/skills/apply
linked /Users/you/.claude/skills/archive -> /Users/you/tools/productflow/skills/archive
... 10 total
```

Because these are symlinks, `git pull` in the clone updates every project at once.

Other harnesses read a different directory:

```bash
./install.sh --target ~/.agents/skills    # Codex, Copilot CLI, Gemini CLI
./install.sh --dry-run                    # print what would happen, change nothing
```

Both targets can coexist — run it twice.

`--dry-run` does not create the target directory, so it is safe on a path you have not committed to yet.

### B. Vendored into the project

Use when the whole team should get the skills by cloning the repo, with no setup step.

```bash
cd /path/to/your-project
mkdir -p .claude
cp -R /path/to/productflow/skills .claude/skills
git add .claude/skills && git commit -m "Add ProductFlow skills"
```

Verified: `cp -R` preserves the executable bit on the six scripts, and they run from
`.claude/skills/productflow/scripts/pf-init` without further setup.

The cost is that updates mean copying again.

### C. Submodule and symlink

Team-wide, and still updatable.

```bash
cd /path/to/your-project
git submodule add git@github.com:kiendd/ProductFlow.git tools/productflow
mkdir -p .claude
ln -s ../tools/productflow/skills .claude/skills
git add .gitmodules tools/productflow .claude/skills
git commit -m "Add ProductFlow as a submodule"
```

The `../` is required. The link lives inside `.claude/`, so a relative target resolves from
there — `ln -s tools/productflow/skills .claude/skills` creates a broken link.

Teammates then run `git submodule update --init`.

### Verify the install

```bash
ls ~/.claude/skills/productflow/SKILL.md          # or your target
~/.claude/skills/productflow/scripts/pf-init --help
```

In a new agent session, ask: *"What skills are available?"* You should see all ten.
Claude Code also has `/reload-skills` if a session was already open.

### Name collisions

The skill names are bare verbs — `brainstorm`, `plan`, `apply`, `update`, `archive`, `prd`,
`propose`, `fix`, `onboard`, `productflow` — so another plugin may already own one.

`install.sh` refuses to clobber anything that is not a symlink:

```
warn: /Users/you/.claude/skills/prd exists and is not a symlink — skipped
one or more skills were skipped
```

It exits `1` so a script notices. Resolve it by renaming the other skill, or by renaming
ProductFlow's: rename the directory under `skills/`, change `name:` in its frontmatter to match,
and update the `productflow:<name>` references in the other skill files. Nothing else depends on
the names.

---

## Part 2 — Integrate into an existing project

### Step 1 — Initialize

From the project root:

```bash
~/.claude/skills/productflow/scripts/pf-init --locale vi
```

This creates:

```
.productflow/config.json     # committed
docs/product/PRD.md          # top-level PRD skeleton
docs/product/index.md        # generated
docs/product/manifest.json   # generated
docs/changes/                # empty
.gitignore                   # appends .productflow/runs/
```

`--locale vi` or `--locale en` sets the language the agent writes PRD prose in. Structure —
frontmatter keys, section headings, `**WHEN**` / `**THEN**` — stays English either way, because
the validator matches it literally.

Running it twice exits `3` and changes nothing.

**The project already uses `docs/` for something else?** Point ProductFlow somewhere else:

```bash
pf-init --docs-root product --changes-root product/changes --locale en
```

Verified against a repo with an existing `docs/` site: the existing directory is untouched, and
`pf-validate` exits 0. Every script reads the roots from config, so nothing else needs changing.

### Step 2 — Build the initial PRD tree

Do not hand-write it. Open an agent session in the project and say:

> Onboard this repository into ProductFlow.

The `onboard` skill will read the code, propose a domain list, and wait for your approval before
writing anything. It stops after three domains so you can review while the reading is still
accurate.

**Already using OpenSpec or Superpowers?** Say so — `onboard` detects `openspec/` and
`docs/superpowers/` and converts them. It reads them as a source and rewrites them as PRDs; it
never imports a file unchanged, and never deletes your originals. Details:
`skills/onboard/references/migrating.md`.

### Step 3 — Commit the right things

| Path | Commit? |
|---|---|
| `.productflow/config.json` | Yes — teammates need the same roots and locale |
| `docs/product/**` | Yes — this is the source of truth |
| `docs/product/index.md`, `manifest.json` | Yes — generated, but agents read them |
| `docs/changes/**` | Yes |
| `.productflow/runs/**` | No — `pf-init` adds the ignore rule |

Verified: after `pf-init`, `git check-ignore` reports `.productflow/runs/x/progress.md` as
ignored.

The generated files are deterministic — sorted keys, indent 2, trailing newline — so they diff
cleanly and will not fight in merges.

### Step 4 — Tell the agent to use it

Add to the project's `AGENTS.md` or `CLAUDE.md`:

```markdown
## Product documentation

This repository uses ProductFlow. Before answering, exploring, or editing anything, read
`docs/product/manifest.json` and follow the `productflow` skill to route to the right one.
Behavior changes go through `propose → plan → apply → archive`, never straight into code.
Bug reports go through `fix`: reproduce, fix, then a short proposal if the PRD was missing the case.
```

Without this, the agent depends on the skill description firing on its own. With it, the routing
is explicit — and repository instructions outrank the skill, which the skills themselves say.

### Step 5 — Confirm it works end to end

```bash
pf-validate            # expect: 0 error(s), 0 warning(s)
```

Then in an agent session, ask for a small behavior change. Expected: the agent announces
`propose`, asks one question at a time, and does **not** write code before you approve. If it
starts editing files immediately, the skills are not loaded — check Step 4 and the install path.

---

## Running the scripts

Scripts walk up from the working directory to find `.productflow/config.json`, so they work from
any subdirectory. Verified from `src/deep/nested/`.

Typing the full path gets old. Either add the directory to `PATH`:

```bash
export PATH="$HOME/.claude/skills/productflow/scripts:$PATH"
```

...or let the agent run them — it has the path from the skill.

| Command | Purpose |
|---|---|
| `pf-init` | Set up ProductFlow in a repository |
| `pf-new-change <slug>` | Scaffold a change folder |
| `pf-reqid <domain> --count N` | Allocate requirement IDs |
| `pf-index` | Regenerate `index.md` and `manifest.json` |
| `pf-validate [--json]` | Check every format rule |
| `pf-archive <slug>` | Retire a finished change |

Exit codes and the fix for each validation finding: `skills/productflow/references/cli.md`.

### Optional: block invalid docs at commit time

```bash
cat > .git/hooks/pre-commit <<'EOF'
#!/usr/bin/env bash
exec ~/.claude/skills/productflow/scripts/pf-validate
EOF
chmod +x .git/hooks/pre-commit
```

`pf-validate` exits `1` when it finds an error, which aborts the commit. In CI, run `pf-index`
first and fail if it produces a diff — that catches a stale `manifest.json`.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `error: not initialized` (exit 7) | No `.productflow/config.json` above the working directory | Run `pf-init` at the project root |
| `pf-init` exits `3` | Already initialized | Nothing to do |
| `warn: … exists and is not a symlink` | Another skill owns that name | Rename one of them — see *Name collisions* |
| Agent ignores the skills | Not installed where the harness looks, or the session predates the install | Check the target directory; `/reload-skills` or restart |
| `manifest-stale` from `pf-validate` | `index.md` / `manifest.json` are behind | Run `pf-index` and commit the result |
| Broken `.claude/skills` symlink | Relative target missing `../` | `ln -s ../tools/productflow/skills .claude/skills` |
| Scripts not executable | Copied without the exec bit | `chmod +x skills/productflow/scripts/pf-*` |

## Uninstalling

```bash
rm ~/.claude/skills/{productflow,brainstorm,propose,fix,plan,apply,update,archive,prd,onboard}
```

Only the symlinks go. Your `docs/product/`, `docs/changes/`, and `.productflow/config.json` are
plain markdown and JSON — they stay readable with no tooling at all.
