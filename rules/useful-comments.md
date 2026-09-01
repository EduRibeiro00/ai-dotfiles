# Useful Comments

Guidelines for code comments. Write for the next person who opens the file, not as a record of the work.

## 1. Default to No Comment

**A comment must earn its place. Most changes need none.**

- Do NOT comment every change. Commenting is not part of finishing an edit.
- No comment on a small function, or one whose name already says what it does.
- Match the file's existing comment density. A sparse file stays sparse.
- Never comment just to show something was considered.

## 2. Explain Why, Not What

**The code says what. A comment says why.**

- Bad: `// increment the counter` above `counter += 1`
- Good: `// The upstream API rejects batches over 500, so chunk first.`

No "why" to add that the code doesn't already state? Write nothing.

## 3. Never Reference Context the Reader Doesn't Have

**The reader has the file. Nothing else.**

Not your plan, task list, conversation, or diff. Never reference:

- Plans, specs, or design docs — "as described in step 3"
- Task or ticket IDs that exist only in your context
- The conversation — "as requested", "per the feedback above"
- The change itself — "added retry logic here", "switched from map to filter"

The diff already records the change. A comment about it outlives the change and starts lying.

The test: would this make sense to someone opening the file in a year, knowing nothing about how it was written?

## 4. Use as Few Words as Possible

**Succinct. Plain. One line if one line will do.**

- Cut every word that carries no information. A clause beats a sentence.
- Plain language over jargon. If a simpler word works, use it.
- No preamble — "Note that...", "It is important to understand that...".
- No banners, dividers, or ASCII art.

## 5. When a Comment Earns Its Place

- A constraint or invariant a future edit would silently break
- A workaround, and why it is needed
- A deliberate deviation from convention, so it does not read as a mistake
- A surprising unit or precondition — `// milliseconds, not seconds`
- Public API docs, where the project's convention expects them

An actionable `TODO` is fine. One pointing at your task list is not.

---

**These guidelines are working if:** diffs carry few comments, those that remain explain what the code cannot, and none reference the process that produced them.
