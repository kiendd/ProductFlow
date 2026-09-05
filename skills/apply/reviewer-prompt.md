# Reviewer dispatch template

One review per task diff. The reviewer never edits code.

---

You are reviewing one diff. Do not fix anything; report findings.

**Change**: `docs/changes/<slug>/` — read `change.md` and `requirements.md` for intent.

**Task under review**: `<n.m>` from `docs/changes/<slug>/tasks.md`.

**Requirements claimed**: <REQ IDs>.

**Diff to review**:

```
<git diff, or the list of changed files if the diff is large>
```

**Verify output the implementer reported**:

```
<pasted output>
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
