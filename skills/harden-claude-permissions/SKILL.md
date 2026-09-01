---
name: harden-claude-permissions
description: Harden Claude Code permissions by adding security deny/ask rules to the user's ~/.claude/settings.json. Adds rules blocking force-push, destructive rm, RCE piping, ssh/scp, AWS destructive ops, and credential reads. Merges with existing settings non-destructively.
disable-model-invocation: true
allowed-tools: Read Bash(ls *) Bash(date *)
---

# Harden Claude Code Permissions

Apply a security baseline to `~/.claude/settings.json` that adds `deny` and `ask` rules. Merges non-destructively — existing `allow` rules, hooks, plugins, model, env, and all other settings are preserved.

## Procedure

1. **Read** the current `~/.claude/settings.json`.
2. **Idempotency check** — inspect the existing `permissions` block:
   - If `deny` already contains ALL rules from the baseline below, report "Already hardened — no changes needed" and stop.
   - If `deny` exists but is missing some baseline rules, report which rules are missing and proceed to add only those.
   - If no `deny` exists, proceed with full baseline.
3. **Dry-run preview** — show the user a summary of what will change:
   - Fields being added (`ask`, `deny`)
   - Number of deny rules being added
   - Confirm no existing settings will be removed
   - Ask the user to confirm before proceeding. If they decline, stop.
4. **Backup** the file to `~/.claude/settings.json.bak.<timestamp>`.
5. **Merge** the baseline permissions below into the existing `permissions` block:
   - Add `ask` and `deny` fields.
   - If `ask` or `deny` arrays already exist, **merge** — combine both lists and deduplicate.
   - Preserve existing `allow` rules exactly as-is.
6. **Write** the updated file.
7. **Verify** by reading the file back and confirming the deny rules are present.
8. **Report** what was added and remind the user to restart Claude Code for changes to take effect.
9. **Cleanup** — ask the user if they want to move the backup file to `/tmp/` to keep `~/.claude/` clean. If yes, move it; if no, leave it in place.

## Baseline to apply

```json
{
  "permissions": {
    "ask": [
      "Bash(rm *)",
      "Bash(sudo *)"
    ],

    "deny": [
      "Bash(git push --force*)",
      "Bash(git push -f*)",
      "Bash(git push --force-with-lease*)",
      "Bash(git push * --force*)",
      "Bash(git push * -f)",
      "Bash(git reset --hard*)",
      "Bash(git clean -f*)",
      "Bash(git checkout -- *)",
      "Bash(git branch -D*)",
      "Bash(git push --no-verify*)",
      "Bash(git commit --no-verify*)",

      "Bash(rm -rf /*)",
      "Bash(rm -rf ~*)",
      "Bash(rm -rf .*)",

      "Bash(curl * | bash*)",
      "Bash(curl * | sh*)",
      "Bash(wget * | bash*)",
      "Bash(wget * | sh*)",

      "Bash(ssh *)",
      "Bash(scp *)",

      "Bash(aws * delete-*)",
      "Bash(aws * terminate-*)",
      "Bash(aws * remove-*)",
      "Bash(aws * purge*)",

      "Bash(terraform apply*)",
      "Bash(terraform destroy*)",
      "Bash(terraform refresh*)",

      "Bash(dd of=/dev/sd*)",
      "Bash(mkfs*)",
      "Bash(chmod 777*)",
      "Bash(chmod -R 777*)",
      "Bash(kill -9 1*)",

      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Read(~/.aws/credentials)",
      "Read(~/.ssh/id_*)",
      "Read(~/.ssh/*_rsa)"
    ]
  }
}
```

## What each category blocks

| Category | Rules | Threat |
|----------|-------|--------|
| Git force operations | `git push --force`, `-f`, `--force-with-lease`, `--no-verify` | Irreversible history destruction |
| Git destructive | `git reset --hard`, `git clean -f`, `git checkout --`, `git branch -D` | Uncommitted work loss |
| Filesystem destruction | `rm -rf /`, `rm -rf ~`, `rm -rf .` | Catastrophic file deletion |
| Remote code execution | `curl|bash`, `curl|sh`, `wget|bash`, `wget|sh` | Arbitrary attacker code execution |
| Network access | `ssh`, `scp` | Lateral movement, data exfiltration |
| AWS destructive | `aws * delete-*`, `terminate-*`, `remove-*`, `purge*` | Production resource destruction |
| Terraform destructive | `terraform apply`, `terraform destroy`, `terraform refresh` | Unintended infrastructure changes |
| Disk/permission | `dd of=/dev`, `mkfs`, `chmod 777`, `kill -9 1` | System-level damage |
| Secret access | `.env`, `secrets/`, `~/.aws/credentials`, `~/.ssh/id_*` | Credential exfiltration |

## Conflict handling

If the user's settings already contain `deny` or `ask` arrays:
- Merge by combining both lists and deduplicating (exact string match).
- Show which rules were already present vs newly added.
- Never silently overwrite existing security rules.
