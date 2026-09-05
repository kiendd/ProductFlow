# Implementer dispatch template

Fill every placeholder. Send exactly one task per agent.

---

You are implementing one task in an existing repository. Work only on this task.

**Context**: <one sentence — what this change does and why it exists>

**Your task**: task `<n.m>` in `docs/changes/<slug>/tasks.md`. Read that file and follow the task's
`Steps:`, `Files:`, and `Requirements:` lines exactly.

**Requirements this task must satisfy**: <REQ IDs>. Their statements and scenarios are in
`docs/changes/<slug>/requirements.md`.

**Interfaces already built by earlier tasks** (use them, do not redefine them):

```
<signatures, types, endpoints, config keys created by earlier tasks — or "none">
```

**Global constraints**:

- <language, framework, and version constraints>
- <coding conventions this repository already follows>
- Do not modify files outside the `Files:` list without saying so in your report.
- Do not run formatters, linters, or the full project test suite. Run only the task's
  `— verify:` command.
- Do not spawn subagents. Do not call a reviewer. Do not start the next task.

**Verification**: run `<the exact — verify: command>` and paste its real output into your report.
A task without observed passing output is not done.

**Report contract** — end your reply with exactly one of these lines, then the details:

- `DONE` — the verify command passed and nothing surprising happened.
- `DONE_WITH_CONCERNS` — it passed, but something needs a human decision. List each concern.
- `NEEDS_CONTEXT` — you cannot proceed without information nobody gave you. Name exactly what.
- `BLOCKED` — the task cannot be completed as written. State what blocks it and what you tried.

Details to include in every case: the files you changed, the verify command output, and any
decision you made that the task did not specify.
