---
name: autopilot
description: Use when the user hands off work to run unattended or autonomously ("autopilot", "work by yourself", "don't wait on me", "only bother me if you must", "I'll review later"), especially across multi-step design or implementation where many judgment calls will come up.
---

# Autopilot

Work without the human, keep a record of every judgment call, and stop only when a wrong guess can't be undone.

## Door test

Before every non-trivial decision, ask: **if this is wrong, can it be undone cheaply, without customer or team impact?**

- **Two-door** (yes): library choice, internal structure, naming, storage shape on an unmerged branch, test layout, anything on a local branch, commits, pushing feature branches, creating draft PRs. Decide and keep going. Asking for autopilot counts as asking to commit and push these.
- **One-door** (no): deploys, prod or shared infra/DB changes (migrations, index drops, backfills), deleting data or resources, merging to a branch that auto-deploys, public API/contract changes, anything customers or the wider team see, spending money, sending messages to others.

A one-door decision is not forbidden. It is forbidden **without full context**. If you can verify the facts that make it safe (read-only checks, the spec, the repo), do that first. Still unsure → stop.

**Never alone, even with full context.** Do these only when the user strictly asks for them:
- Taking a draft PR out of draft (publishing it for review).
- Merging a PR. Forbidden, full stop.
- Pushing to `main` or the default branch. Forbidden, full stop.
- Leaving comments or reviews on PRs or issues, or replying to others.

Context can't make these safe: they notify the team. "Autopilot" is not a request for them. Leave the PR as a draft and report it in the summary.

## Flow

1. Classify: one-door or two-door.
2. Gather context (code, docs, read-only queries). Never guess what you can look up.
3. List the options, with pros/cons when they aren't obvious.
4. **Two-door:** pick one, write it to `JOURNAL.md`, proceed.
   **One-door without enough info:** stop.

If the irreversible step can be deferred without blocking the rest (leave the migration unrun, the branch unmerged, the constraint out), defer it, journal it, and continue. Stop only when the task can't progress, or can't be called done, without it.

## When you stop

Present the dilemma: what you need to decide, the options, what you couldn't verify, and why a wrong choice is irreversible. Say plainly that you lacked the info to choose. Don't act on a best guess, and don't treat "get it live" or "I'm offline" as that approval. Then give the end-of-run summary.

## JOURNAL.md

A running log of the run: decisions, plus breakthroughs, observations, discoveries, conclusions and progress checkpoints. Place it next to the specs/plans for this session; if none exist, in the working directory. Subagents append to the same file, or report decisions to the orchestrator, who records them. A subagent that hits a one-door decision returns it to the orchestrator and does not proceed.

Append an entry as each thing happens, not at the end. Decision:

```markdown
## <short title>
**Context:** <what forced the decision>
**Options:** <A: ... / B: ... (pros/cons if needed)>
**Chose:** <option> — <why>
```

Note (breakthrough, observation, checkpoint):

```markdown
## <short title>
**Note:** <what you found or reached, and why it matters>
```

Every decision entry has all four fields; for a trivial call, one alternative under Options is enough.

## End-of-run summary

On any stop (done or blocked), reply with: tasks done, outcome, key decisions (point to `JOURNAL.md`), anything deferred or needing the human.

## Red flags

| Thought | Reality |
|---|---|
| "It's probably fine, they said not to wait" | Time pressure is not context. Defer or stop. |
| "I'll flag it in the final message" | Flagging after an irreversible action is too late. |
| "Small decision, no need to log it" | If you weighed options, log it. Two lines is enough. |
| "I'll ask them about this two-door choice" | You were told to decide. Decide and record. |
