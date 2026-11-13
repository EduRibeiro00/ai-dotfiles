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
| Any code-related task: writing, reviewing, researching, inspecting, debugging, planning. Read-only tasks included | `superpowers:using-superpowers` |
| Planning or changing anything that isn't code (design, docs, config). Skip only for questions and small one-off lookups | `superpowers:using-superpowers` |
| Writing or reviewing code. Subagents that write or review code must invoke it too: say so in their prompt | `ponytail` |
| The user hands off work to run unattended ("work by yourself", "I'll review later") | `autopilot` |
| AWS is touched in any way (CLI, SDK, console, credentials), even read-only | `aws-account-access`. **ALWAYS.** |
| Any git commit | `commit-message-conventions` |
| Any pull request created or updated | `github-pr-conventions` |
| Writing a document or artifact others can see outside the local repo, PR descriptions included | `technical-writing` |
| You need to discuss, debate or decide something with the human | `grill-me` |

Where these skills conflict with superpowers defaults, these win.

## Subagents

Delegate to subagents by default; do the work inline only when it is a handful of tool calls. Pick the model and effort by task:

| Task | Model | Effort |
|---|---|---|
| Implementation, writing code, research | Sonnet | medium |
| Planning, reviewing code, debugging | Opus | high |

## Red flags

| Thought | Reality |
|---|---|
| "Tiny commit, convention doesn't matter" | All commits and PRs use the convention skills. |
| "Just a read-only AWS call" | Still `aws-account-access`. |
| "I'll ask a quick question inline" | Discussion with the human goes through `grill-me`. |
| "It's a small change, no need for superpowers" | Changing things means `using-superpowers`. Only small non-code questions and lookups skip it. |
| "I'm only reading code, no need for superpowers" | Any code task, read-only included, means `using-superpowers`. |
| "The subagent will figure out ponytail itself" | Tell code-writing and code-reviewing subagents to invoke `ponytail`. |
| "I'll invoke it once I've started" | Before, not after. |
