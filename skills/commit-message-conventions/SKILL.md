---
name: commit-message-conventions
description: MUST USE before any git commit. Load proactively whenever committing code, creating commits, or when the user asks to commit changes. Ensures consistent single-line format with conventional prefixes (feat/fix/chore/refactor/docs/test).
---

# Git Commit Message Guidelines

## Format

Commit messages must be a single line:

```
<prefix>: <one-line description of changes>
```

## Prefix

Use a prefix that describes the nature of the change:

- `feat:` — new feature
- `fix:` — bug fix or correction
- `chore:` — small configuration change, dependency update, cleanup
- Other prefixes are acceptable if they fit better (e.g. `refactor:`, `docs:`, `test:`)

## Convention

Before writing the commit message, run `git log --oneline` in the repo to see recent commit messages and match the existing style. If the existing style differs from the format above, prefer the repo's convention.

## Rules

- Always use `git commit -m "<message>"` — do not use HEREDOCs, multi-line messages, or the Co-Authored-By trailer.
- Keep the message concise — one short sentence after the prefix.
