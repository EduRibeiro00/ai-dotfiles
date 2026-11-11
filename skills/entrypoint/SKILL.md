---
name: entrypoint
description: Use at the start of a thread or session, when the user invokes /entrypoint, or when unsure which workflow skill applies to the current task.
---

# Entrypoint

Routes work to the right skill at the right moment. Invoke the matching skill **before** acting, never after. Triggers also fire mid-task: re-check them whenever the work changes stage.

First, read the repo's `AGENTS.md` and `context/` folder if they exist.

## Triggers

| When | Invoke |
|---|---|
| Planning or changing anything (design, feature, refactor, migration, code change). Skip only for questions and small one-off lookups | `superpowers:using-superpowers` |
| Code will be changed | `ponytail` |
| The user hands off work to run unattended ("work by yourself", "I'll review later") | `autopilot` |
| AWS is touched in any way (CLI, SDK, console, credentials), even read-only | `aws-account-access`. **ALWAYS.** |
| Any git commit | `commit-message-conventions` |
| Any pull request created or updated | `github-pr-conventions` |
| Writing a document or artifact others can see outside the local repo, PR descriptions included | `technical-writing` |
| You need to discuss, debate or decide something with the human | `grill-me` |

Where these skills conflict with superpowers defaults, these win.

## Red flags

| Thought | Reality |
|---|---|
| "Tiny commit, convention doesn't matter" | All commits and PRs use the convention skills. |
| "Just a read-only AWS call" | Still `aws-account-access`. |
| "I'll ask a quick question inline" | Discussion with the human goes through `grill-me`. |
| "It's a small change, no need for superpowers" | Changing things means `using-superpowers`. Only questions and lookups skip it. |
| "I'll invoke it once I've started" | Before, not after. |
