# ProductFlow CLI

Six executables in `skills/productflow/scripts/`. Run them from anywhere inside the product
repository — each one walks up to the directory containing `.productflow/config.json` and works
from there. All paths they print are relative to that root.

## Commands

| Command | What it does | Exit |
|---|---|---|
| `pf-init [--docs-root P] [--changes-root P] [--locale vi\|en] [--title T]` | Creates `.productflow/config.json`, the top-level `docs/product/PRD.md` skeleton, `docs/changes/`, the `.gitignore` entry, then runs the indexer | `0`; `3` already initialized |
| `pf-new-change <slug> [--title T] [--design] [--classification bounded\|architectural]` | Creates `docs/changes/<slug>/` from the templates; `design.md` only with `--design` | `0`; `2` bad slug; `4` already exists |
| `pf-reqid <domain> [--count N]` | Prints the next N unused requirement IDs, one per line | `0`; `2` bad usage |
| `pf-index` | Regenerates `docs/product/index.md` and `docs/product/manifest.json` | `0` |
| `pf-validate [--json] [--path P]` | Runs every format rule plus internal links and manifest freshness | `0` clean; `1` findings exist |
| `pf-archive <slug> [--date YYYY-MM-DD] [--force]` | Sets `status: archived`, adds `archived:`, moves to `archive/<date>-<slug>/`, reindexes, revalidates | `0`; `5` unchecked tasks; `6` delta not merged |

Shared codes: `2` usage error, `7` not initialized (run `pf-init`).

`pf-validate` takes `--json`. Every other command prints one JSON summary line on stdout.

## Config

`.productflow/config.json` is committed:

```json
{
  "version": 1,
  "docs_root": "docs/product",
  "changes_root": "docs/changes",
  "prd_locale": "vi",
  "requirement_prefix": "REQ"
}
```

`prd_locale` accepts `vi` or `en`; it sets the language of generated labels and the language the
skills write PRD prose in. Any other value falls back to `en` labels with a warning on stderr.

## Requirement IDs

`REQ-<PREFIX>-<NNN>`. `<PREFIX>` is the first path segment of the domain, uppercased, with any
character outside `[A-Z0-9-]` replaced by `-` (`identity/user-auth` → `IDENTITY`). `pf-reqid`
scans every `docs/product/**/PRD.md` **and** every `docs/changes/**/requirements.md`, including
the archive, so parallel changes never collide. Never reuse a retired number.

## Common sequences

Start a change:

```bash
pf-new-change add-invoice-pdf --design
pf-reqid billing --count 2
```

Check work before handing back:

```bash
pf-index && pf-validate
```

Finish a change (only after the delta is merged into the PRD tree):

```bash
pf-archive add-invoice-pdf
```

## When pf-validate reports a finding

Fix the document; never silence the check.

| Code | Fix |
|---|---|
| `frontmatter-syntax` | Frontmatter must be `---`, then plain `key: value` lines, then `---`. No nesting, no multiline, no comments, no blank lines |
| `frontmatter-missing-key` | Add the named key. PRDs need `id`, `title`, `type`, `domain`, `status`, `updated`; change files need `id`, `title`, `status`; deltas and task lists need `change` |
| `frontmatter-bad-value` | `type` ∈ `product\|domain\|capability`; PRD `status` ∈ `draft\|active\|deprecated`; change `status` ∈ `draft\|planned\|in-progress\|implemented\|archived`; `classification` ∈ `bounded\|architectural`; `updated` is `YYYY-MM-DD` |
| `id-path-mismatch` | The `id` is derived from the path: `docs/product/billing/invoicing/PRD.md` → `product.billing.invoicing`. Move the file or fix the `id` |
| `section-missing` | Add the missing `## ` heading. Empty sections must still exist |
| `section-order` | Reorder the ten PRD sections into the canonical order |
| `req-format` | Heading must be `### REQ-<PREFIX>-<NNN>: <title>` with `**Status**:` and `**Statement**:` directly under it |
| `req-duplicate` | The ID already exists elsewhere in the tree. Allocate a fresh one with `pf-reqid` |
| `req-no-scenario` | Add at least one `#### Scenario: <name>` |
| `scenario-no-when-then` | Each scenario needs a bullet with `**WHEN**` and a bullet with `**THEN**` |
| `delta-missing-target` | ADDED and MODIFIED entries need `**Target**: <id of the destination PRD>` |
| `delta-modified-incomplete` | MODIFIED must restate the whole requirement: statement plus every scenario, not just the diff |
| `delta-removed-no-reason` | REMOVED needs `**Reason**:` and `**Migration**:` |
| `task-format` | Checkbox must be `- [ ] <n>.<m> <text> — verify: <command>` with `- Requirements:`, `- Files:`, `- Steps:` beneath it |
| `link-broken` | The relative link target does not exist. Fix the path or create the file |
| `manifest-stale` | Run `pf-index` and commit the regenerated `index.md` and `manifest.json` |

Full format specification: skill `productflow:prd`, file `../../prd/references/prd-format.md`.
