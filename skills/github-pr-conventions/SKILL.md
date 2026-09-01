---
name: github-pr-conventions
description: MUST USE before creating or updating any GitHub pull request. Load proactively when creating a PR, pushing a branch for review, running `gh pr` commands, or when the user mentions "pull request", "PR", "gh", or "GitHub review". Defines formatting, branch setup, and workflow conventions for the `gh` CLI.
---

# GitHub Pull Request (PR) Guidelines

When creating or updating pull requests using the `gh` CLI, follow these conventions.

## Guardrails

- **Never `git push` directly to the default/main branch** (`main`, `master`,
  `mainline`, or whatever the repo's default branch is called). All changes go through
  a PR on a feature branch, even small ones.
- **Never merge a PR yourself** — not via `gh pr merge`, not via the GitHub UI. Merging
  is the user's decision to make; open or update the PR and hand it back to them.

## Detecting the base branch

Before setting the upstream or rebasing, detect the repository's default branch:

```
gh repo view --json defaultBranchRef -q .defaultBranchRef.name
```

Use this value as `<BASE_BRANCH>` in all subsequent steps.

**Do not assume `main`.** Repos still on `master`, or using a release branch such as
`develop`, are common. If the user's work is meant to target a branch other than the
default (e.g. a release train), ask rather than guessing.

## Pushing the branch

The branch must exist on the remote before the PR can be created:

```
git push -u origin HEAD
```

This both pushes and sets the upstream. To check the upstream:
`git rev-parse --abbrev-ref --symbolic-full-name @{u}`

If you pass `--head` to `gh pr create`, gh skips pushing entirely and assumes the
branch is already on the remote — so push first regardless.

**Never force-push a branch under active review without telling the user.** It
detaches existing review comments from their lines.

## Rebasing before creating a PR

Fetch the latest changes from the base branch and rebase your work on top:

```
git fetch origin
git rebase origin/<BASE_BRANCH>
```

This keeps the PR diff clean and avoids merge conflicts during review. Rebase
*before* the first push, so no force-push is needed.

## Creating a PR

Always provide `--title` and a body. Because PR bodies are multi-line markdown,
write the body to a temp file and pass `--body-file` — this avoids shell quoting and
escaping problems that `--body "..."` runs into with backticks and newlines.

**Always pass `--draft` unless the user says otherwise.** A draft cannot be merged and
signals the work is not up for review yet, which leaves room to fix up the branch
before anyone spends time on it.

**Standard case:**

```
gh pr create --draft --base <BASE_BRANCH> --title "<TITLE>" --body-file <BODY_FILE>
```

**With reviewers and labels:**

```
gh pr create --draft --base <BASE_BRANCH> --title "<TITLE>" --body-file <BODY_FILE> \
  --reviewer <HANDLE_A>,<HANDLE_B> --label <LABEL>
```

**Ready for review immediately** — only when the user explicitly asks for it (e.g.
"open it ready", "not a draft", "request review now"):

```
gh pr create --base <BASE_BRANCH> --title "<TITLE>" --body-file <BODY_FILE>
```

Promote a draft once the work is ready:

```
gh pr ready [<NUMBER>]
```

Marking a PR ready is also what requests reviews from any code owners, so do not
promote it until CI is green and the description is final.

Do **not** use `--fill` or `--fill-verbose` when these conventions apply: they derive
the title and body from commit messages, which will not match the description format
below.

### Changes spanning multiple repositories

A PR belongs to exactly one repository, and no single PR can span several. If a
change spans repos, open one PR per repo and
cross-link them in each description's "Relevant links" section. State the intended
merge order explicitly, since GitHub will not enforce it across repos.

## Stacked PRs (dependencies)

Express a dependency by targeting the upstream PR's branch as your base:

```
gh pr create --draft --base <UPSTREAM_BRANCH> --title "<TITLE>" --body-file <BODY_FILE>
```

The PR then shows only the incremental diff against the upstream branch. Note in the
description which PR must merge first.

After the upstream PR merges, verify the dependent PR's base and retarget it if
needed — do not assume GitHub has done this for you:

```
gh pr view <NUMBER> --json baseRefName -q .baseRefName
gh pr edit <NUMBER> --base <BASE_BRANCH>
```

## PR Title Format

The `--title` value must be a one-liner using a conventional-commit prefix:

```
<prefix>: <one-line description of changes>
```

Choose the prefix that describes the nature of the change: `feat:` for a new
feature, `fix:` for a bug fix, `chore:` for a config change, dependency update, or
cleanup. Other prefixes are fine when they fit better — `refactor:`, `docs:`,
`test:`. Keep the description short, lowercase, and in the imperative mood.

```
feat: add retry budget to review fetch
fix: handle null author in decoration path
chore: bump jackson to 2.17.1
```

Do not prefix the title with the repository name — the repo is implicit in the PR.

**Convention check:** run `gh pr list --state all --limit 20 --json title -q '.[].title'`
to see recent titles in the repo. If the existing style differs from the format
above, prefer the repo's convention.

## PR Description Format

Before writing the description, check whether the repo defines a PR template:

```
gh repo view --json pullRequestTemplates -q '.pullRequestTemplates[].filename'
```

Templates live at `pull_request_template.md` in the repo root, `docs/`, or
`.github/`; repos with several templates keep them in a `PULL_REQUEST_TEMPLATE/`
subdirectory of one of those locations. If a template exists, follow it.

If no template exists, use this format:

```markdown
### Updates

* Update 2: <main differences between update 2 and update 1>
* Update 1: initial submission

---

### Summary

<overall summary of changes, 3-4 sentences max>

### Changes

<bullet points describing the most important changes>

### Testing

<bullet points describing how the changes were tested>

### Relevant links

<bullet points with relevant links (issues, docs, related PRs)>
```

Rules for optional sections:
- "Updates" section: only include once there has been at least one update round
  (see "Checking PR state before updating").
- "Relevant links" section: omit if there are no relevant links.

To close an issue on merge, put `Fixes #<N>` or `Closes #<N>` in the body.

## PR Description Content Rules

These rules apply regardless of which template shapes the description (the repo's PR
template or the default format above). Section names vary by template.

- **Keep the PR description concise and high level.**
- **Audience:** the description is read by reviewers who have no access to the
  author's planning context. NEVER include task-tracker-local information — task
  IDs, epic or sprint names, or links pointing at internal planning artifacts. On a
  public repo this also risks leaking internal detail. Describe the motivation and
  follow-up work in plain language instead. The "Relevant links" section is for
  artifacts reviewers can act on (issues, design docs, related PRs), not
  planning-tool items.
- **Using backticks for code:** Use backticks when referencing code identifiers: class names
  (`GetReviewByIdHandler`), service names (`SingleReviewService`), method names
  (`buildQuery()`), config keys, repo names, or variable names.
- **Summary section:** if the PR includes multiple changes, explicitly state that it
  does and WHY they ship in one PR.
- **Changes section:** high-level information only — what changed and why it works.
  Do NOT enumerate low-level details such as emitted metric names or edge cases; the
  diff carries those.
- **Testing section:** do NOT enumerate unit test cases. State that tests were run
  and are green (unit, build, functional — as applicable). Provide detail ONLY for
  newly created integration-testing setups or manual testing procedures.
- **Reviewers:** assign reviewers per project/team conventions — NEVER the PR
  author (GitHub rejects self-review requests anyway). If no reviewer convention is
  known, ask the user before creating the PR rather than guessing. Check
  `.github/CODEOWNERS` first; if it covers the changed paths, those owners are
  requested automatically and no `--reviewer` flag is needed.

## Checking PR state before updating

Before editing an existing PR, query its current state:

```
gh pr view <NUMBER> --json number,url,isDraft,state,reviewDecision,reviews,body
```

From the response, extract:

- `isDraft` — whether the PR is still a draft
- `state` — `OPEN`, `MERGED`, or `CLOSED`
- `reviewDecision` — `REVIEW_REQUIRED`, `APPROVED`, `CHANGES_REQUESTED`, or empty
- `reviews` — the review events so far; an empty array means nobody has reviewed yet

Use this to decide how to update the description:

- **`isDraft` is true, or `reviews` is empty**: nobody has reviewed yet. Update the
  description in place (summary/changes/testing) without adding an "Updates" bullet.
- **`reviews` is non-empty**: a reviewer has already looked at this. Add a new bullet
  at the top of the "Updates" section. If the section does not exist yet, create it,
  seeding it with a bullet for update 1 (initial submission) below the new one.
- **`state` is `MERGED` or `CLOSED`**: do not edit. Tell the user and ask how to
  proceed.

## Adding an update round

Push the new commits, then record the update in the description.

1. Push the follow-up commits:

   ```
   git push origin <branch_name>
   ```

   Prefer adding commits over amending and force-pushing, so reviewers can see the
   incremental diff and existing comments stay anchored.

2. Update the description. `--body` and `--body-file` **replace** the entire body,
   so always pass the full updated text — including the new "Updates" bullet:

   ```
   gh pr edit <NUMBER> --body-file <FULL_UPDATED_BODY_FILE>
   ```

   The new "Updates" bullet should carry enough detail for a reviewer to know where
   to look again — what changed since the last review, and which feedback it
   addresses.

3. If the PR is still a draft and the work is now ready for review:

   ```
   gh pr ready <NUMBER>
   ```

Before asking for re-review, confirm CI is green with `gh pr checks <NUMBER>`.

## Reporting the PR link

After creating a PR or posting an update, always return the full PR URL to the user:

```
https://github.com/<OWNER>/<REPO>/pull/<NUMBER>
```

`gh pr create` prints this URL on success; otherwise get it with
`gh pr view <NUMBER> --json url -q .url`. Do not return only the PR number or a bare
repo link.
