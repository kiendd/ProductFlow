# Reviewer dispatch template

One review per task group (or the whole change at close-out). The reviewer never edits code.

---

You are reviewing the combined diff of one task group. Do not fix anything; report findings.

**Change**: `docs/changes/<slug>/` — read `change.md` and `requirements.md` for intent.

**Tasks under review**: group `<n>` (tasks `<n.1>`…`<n.k>`) from `docs/changes/<slug>/tasks.md`.

**Requirements claimed**: <REQ IDs>.

**Combined diff to review**:

```
<git diff, or the list of changed files if the diff is large>
```

**Verify output each implementer reported, per task**:

```
<task <n.1>: pasted output>
<task <n.2>: pasted output>
…
```

Review along exactly three axes.

**1. Does it satisfy the claimed requirements?**
Read each claimed REQ's statement and scenarios. For each one, name the code that implements it.
A requirement with no corresponding code is a finding, even if the tests pass.

**2. Do the tests actually prove the behavior?**
A test that asserts a mock was called, asserts nothing, or restates the implementation does not
prove behavior. Each scenario in the claimed requirements should map to an assertion. Name the
scenarios that are unproven.

**3. Quality.**
Duplication of logic that already exists in the repository; misleading names; error paths that
swallow failures; edge cases the requirement names but the code ignores; changes to files
outside the task's declared scope.

**Report contract** — end with either:

- `APPROVED` — no finding blocks the next task.
- A findings list. One line each: `<severity> — <file>:<line> — <what is wrong> — <what to do>`,
  where severity is `blocker`, `major`, or `minor`.

Do not comment on formatting, import order, or style the project's tooling already handles.
