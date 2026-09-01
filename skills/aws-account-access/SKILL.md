---
name: aws-account-access
description: MUST USE before running any AWS CLI command. Provides the correct procedure for obtaining AWS credentials via IAM Identity Center (AWS SSO) and executing `aws` commands with the appropriate profile and region. Enforces read-only by default; requires explicit user confirmation for write/admin access.
---

# AWS Account Access

How to obtain credentials and run AWS CLI commands against a specific AWS account.

## Credential Acquisition

Credentials come from a **named profile** — one per account + role combination. Profiles
are defined once in `~/.aws/config`. After that, a single `aws sso login` per session
covers every profile sharing that SSO session; reuse the profile for subsequent `aws`
commands until the session expires.

### Resolving a natural-language account reference

The user will often name an account by alias/environment instead of a profile (e.g.
"the marketing dev account", "prod", "check EKS on the shared-services account") rather
than giving `--profile` directly. Resolve this before running anything:

1. List existing profiles: `grep '^\[profile' ~/.aws/config`.
2. Match the alias/environment keywords the user used against profile names,
   case-insensitively (e.g. "marketing dev" → `marketing-dev-readonly`). If they didn't
   state a privilege level, default to read-only per the Rules below.
3. **Exactly one match** for the alias + privilege level → use it.
4. **Multiple candidates** (e.g. both `-readonly` and `-admin`, or more than one alias
   could fit) → ask the user which profile they mean instead of guessing.
5. **No match** → tell the user no profile exists for that account, and offer to create
   one via the interactive setup below, naming it from the alias (e.g.
   `marketing-dev-readonly`) with `ReadOnlyAccess` unless they asked for another role.
   Confirm before running it — it opens a browser auth flow and writes to
   `~/.aws/config`.

### Profile setup (once per account + role)

Set up interactively — this prompts for the start URL and lists the accounts and roles
available to you:

```bash
aws configure sso --profile <profile_name>
```

Or write `~/.aws/config` directly:

```ini
[sso-session my-org]
sso_start_url = https://<my-org>.awsapps.com/start
sso_region = <sso_region>
sso_registration_scopes = sso:account:access

[profile <account_alias>-readonly]
sso_session = my-org
sso_account_id = <account_id>
sso_role_name = ReadOnlyAccess
region = <region>

[profile <account_alias>-admin]
sso_session = my-org
sso_account_id = <account_id>
sso_role_name = AdministratorAccess
region = <region>
```

Name profiles so the privilege level is visible at a glance (`-readonly`, `-admin`).
Prefer the `sso-session` form above over putting `sso_start_url` directly in the
profile — the shared-session form refreshes tokens correctly.

**Important:** `sso_region` is where Identity Center lives; `region` is where the
resources are. They are often different — do not conflate them.

### Logging in (once per session)

```bash
aws sso login --sso-session my-org
```

Then confirm which identity you are actually operating as:

```bash
AWS_PROFILE=<profile_name> aws sts get-caller-identity
```

Do this before any write action. The returned account ID and role must match the
account and privilege level you intend to act on.

### Read-Only (default)

Always use read-only unless the user explicitly requests a write action.

```bash
AWS_PROFILE=<account_alias>-readonly AWS_REGION=<region> aws <command>
```

### Admin (write access)

Only use when the action cannot be performed with read-only AND the user has explicitly
confirmed the write action.

```bash
AWS_PROFILE=<account_alias>-admin AWS_REGION=<region> aws <command>
```

### Custom Role

When the user specifies a different role, add a profile with that permission set as
`sso_role_name` and a descriptive suffix (e.g. `oncall`, `deploy`, `audit`):

```ini
[profile <account_alias>-<role_suffix>]
sso_session = my-org
sso_account_id = <account_id>
sso_role_name = <PermissionSetName>
region = <region>
```

**Important:** Permission set names vary per organization — do NOT guess them. If the
name is unknown, run `aws configure sso` to list what is available, or ask the user.

## Rules

1. **Default to read-only.** If the user asks to "check", "describe", "list", "get", or "look at" something, use read-only credentials.
2. **Never assume admin without explicit permission.** If a task requires write access, explain what you need to do and ask the user to confirm before using an admin profile.
3. **Verify identity before writes.** Run `aws sts get-caller-identity` and confirm the account and role are the intended ones.
4. **Re-authenticate on expiry.** If an `aws` command fails with an expired-session or expired-token error, re-run `aws sso login` and retry.
5. **Always set both AWS_PROFILE and AWS_REGION.** Never rely on the default profile or region.
6. **One account at a time.** If working across multiple accounts, use a separate profile per account and pass it explicitly on every command.

## Expired Credentials Recovery

Two distinct failure families, with different fixes:

**SSO session expired** — messages like:
- `Error loading SSO Token`
- `The SSO session associated with this profile has expired`
- `Token has expired and refresh failed`

Fix: `aws sso login --sso-session my-org`, then retry the failed command.

**STS credentials expired** — messages like:
- `ExpiredToken`
- `The security token included in the request is expired`
- `InvalidClientTokenId`

Fix: `aws sso login` as above, then retry. If it recurs immediately, check for stale
environment variables (below) before re-authenticating again.

**Stale environment variables** — these silently override `AWS_PROFILE` and are a
common cause of "wrong account" and phantom auth errors. Credential precedence is
command-line flags → environment variables → credentials file → config file →
container credentials → instance metadata.

Diagnose and clear:

```bash
aws configure list   # shows each value in effect and where it came from
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
```

## Access Denied That Is Not a Credentials Problem

`AccessDenied` on valid, unexpired credentials usually means an organization policy
denies the action — a Service Control Policy, a permission boundary, or an explicit
deny in the role's policy. Re-authenticating will not help.

1. **Stop.** Do not retry in a loop — it will keep failing.
2. Report the exact error, the role from `aws sts get-caller-identity`, and the action attempted.
3. Tell the user the action appears blocked by policy rather than by missing credentials, and let them decide how to proceed (request elevated access, use a different role, or take another route).
