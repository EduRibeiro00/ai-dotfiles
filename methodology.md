# Agentic Development Methodology

This document captures the overall philosophy for how I want to work with coding agents, and how agents should work with each other. It's a living reference for the principles and workflows behind this repo's skills, rules, and settings — not a spec or an implementation plan.

## 1. Foundation

The basis for all of this is [obra/superpowers](https://github.com/obra/superpowers). There's no need to reinvent plan writing, TDD, git worktrees, implementer-reviewer loops, file-based context handoffs, or a meta-skill for writing better skills — superpowers already provides a solid foundation for all of it.

Our job is not to replace this framework, but to extend and adapt it to our own needs.

## 2. Autonomy & Guardrails

The goal is to run agents in "bypass permissions" mode most of the time. That's only safe if the agent is well guardrailed in what it can and cannot do — which is why skills like `harden-claude-permissions` and `aws-account-access` exist: they constrain the blast radius so autonomy doesn't come at the cost of safety.

## 3. Version Control Conventions

Commits and PRs should always go through our convention skills (`commit-message-conventions`, `github-pr-conventions`), never ad hoc.

## 4. Repo Context

Every repo an agent works in should give it enough context to operate well:

- **`AGENTS.md`** is the single source of truth: overall repo/codebase information, architectural decisions, conventions, and anything else an agent needs to know before making changes.
- **`CLAUDE.md`** exists only to point Claude Code at it, with exactly this content:

  ```
  # <NAME_OF_REPO>

  Project steering lives in `AGENTS.md` (tool-neutral, single source of truth, read by every agent). Claude Code reads it via the import below.

  @AGENTS.md
  ```

- When there's more context than fits comfortably in `AGENTS.md`, a **`context/`** folder can hold additional `.md` files, with `AGENTS.md` pointing to or mentioning it.
- If some of that context actually lives elsewhere (e.g. wikis, design docs), we can build a way to "pull" those changes into the `context/` folder — potentially automated with a hook — so the context folder stays a synced local copy rather than going stale.
- For a bigger project spanning multiple repos, we can go a step further with a meta/harness repo: a repo that holds only context files (and no code of its own), with a `workspace/` subfolder where all the actual project repos get cloned. Agent sessions are then started from the root of this harness repo, so every session has the full cross-repo context plus access to all the repos it might need to touch.

## 5. Extending Superpowers

`using-superpowers` is the default entrypoint of the Superpowers skill set — it's what causes the agent to invoke the other skills. We should build our own version of this entrypoint: one that still drives the underlying superpowers skills, but also layers in whatever we've added on top and enforces our own conventions.

Ways to expand on the base framework:

- More reviewer subagents, each with more specific, targeted checks.
- Implementer agents that call additional skills as part of their normal flow (e.g. "ponytail").

## 6. Planning & Increments

The dev workflow should always prioritize planning before building:

- Spend real time defining what we want to do first — `brainstorming` and `writing-plans` are the right skills for this. Plans get written to `.md` files, not left in conversation.
- Plans should be broken into increments: individual, self-contained changes that build and can be deployed on their own, with later increments building on top of earlier ones. Increments should form a DAG — or at minimum a sequential chain.

## 7. Ticket Tracking Integration

A "backlog" skill can act as the bridge between agents and whatever project/ticket tracker we use (e.g. Jira). Once a plan is settled, this skill creates tickets for its tasks/increments, and keeps them updated as work progresses.

## 8. Stacked PRs & Review Feedback

Because increments build on top of each other, one increment should map to one PR by default, using stacked PRs. Agents need to know how to:

- Read review comments.
- Implement the requested fixes/changes.
- Rebase the stack correctly.
- Identify which other PRs in the stack are affected by a given change.
- Resubmit the affected PRs for review.

## 9. Cross-Session Agent Collaboration

We should promote communication and feedback loops between agent sessions rather than treating each session as isolated. For example: one agent runs a job and it fails; it diagnoses the error and proposes a fix to a second agent that holds the full implementation context; that second agent applies the fix, runs the build, and messages the first agent to redeploy and re-run the job. Naming sessions makes it easier to identify which agent is which in these handoffs.

## 10. Autonomous Operation

We want it to be easy to run agents autonomously — e.g. an "autopilot" skill. A few things matter for this to be safe and legible:

- The agent should maintain a `JOURNAL.md` of everything it did. Instead of relying on someone asking "what did you do?", the answer should already be recorded in a file.
- When facing a tough or ambiguous decision, the agent should first classify it:
  - **Easily reversible** — record the decision in a file (e.g. `CHECK_WITH_HUMAN.md`), explain the options considered and why one was chosen, and continue autonomously.
  - **Irreversible, or with real consequences** — stop development entirely and block, waiting for human input.
- Beyond files, this information could also be pushed to a chat app (e.g. Slack), so a human can quickly see when their intervention is actually needed.

## 11. Scaling Code Review

The `code-review` skill lets agents automatically review PRs made by others, so code review doesn't become the bottleneck as more work is agent-generated.

## 12. Scheduled Agent Jobs

We should have a way to run agent jobs automatically and periodically via cron — for things like recurring code review sweeps, handling oncall tickets, or making ongoing code improvements.

## 13. General Operating Principles

- Let big, verbose tasks be handled by subagents rather than bloating the main session's context.
- Parallelize as much as possible — subagents, worktrees, and similar mechanisms.

## References

- [obra/superpowers](https://github.com/obra/superpowers) — the software development methodology this builds on.
- [Frontier Engineering — kiro.dev](https://kiro.dev/topics/frontier-engineering/)
