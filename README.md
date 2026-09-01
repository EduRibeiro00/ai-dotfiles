# AI Dotfiles

A repository for managing Claude Code and OpenCode configurations, skills, rules, and settings.

## Directory Structure

- **`skills/`** - Custom skill definitions for Claude Code and OpenCode
  - Skills extend Claude's capabilities for specialized tasks
  - Each skill is a folder or `.md` file with instructions

- **`rules/`** - Custom rules and guidelines
  - Organization-level instructions
  - Project-specific rules
  - Team guidelines

- **`settings/`** - Configuration files and settings
  - `settings.json` - Claude Code harness settings
  - `statusline-command.sh` - Custom status line script
  - Other configuration files

- **`scripts/`** - Sync and setup scripts
  - `claude_sync.sh` - Syncs to Claude Code config directory
  - `opencode_sync.sh` - Syncs to OpenCode config directory

## Configuration Locations

- **Claude Code:** `~/.claude/`
- **OpenCode:** `~/.opencode/`

## Installation & Syncing

### Sync to Claude Code

Run the Claude sync script to copy skills, rules, and settings:

```bash
./scripts/claude_sync.sh
```

**What it does:**
- Syncs skills from `skills/` to `~/.claude/skills/`
- Syncs rules from `rules/` to `~/.claude/rules/`
- Syncs settings from `settings/` to `~/.claude/`
- Shows an `Overwrite? (y/N):` prompt for each item that already exists
- Only copies what you confirm

**Example output:**
```
=== Claude Code Sync ===

Claude Config Directory: /Users/user/.claude

Skills
⚠ aws-account-access already exists:
  /Users/user/.claude/skills/aws-account-access
Overwrite? (y/N): y
Replacing aws-account-access...
✓ Synced aws-account-access

Rules
✓ Synced aws-production-safety.md

Settings
✓ Synced settings.json
✓ Synced statusline-command.sh

=== Sync Complete ===
```

### Sync to OpenCode

Run the OpenCode sync script to copy skills and rules:

```bash
./scripts/opencode_sync.sh
```

**What it does:**
- Syncs skills from `skills/` to `~/.opencode/skills/`
- Syncs rules from `rules/` to `~/.opencode/rules/`
- Shows an `Overwrite? (y/N):` prompt for each item that already exists
- Only copies what you confirm

## Sync Behavior

The sync scripts work item-by-item, not with bulk folder operations:

- **Individual file/folder syncing** — Each skill, rule, or setting is synced separately
- **Granular overwrite control** — You get prompted for each item that already exists
- **No destructive operations** — Files are never deleted, only replaced on your confirmation
- **Safe for team use** — Team members can selectively update what they need

## Adding New Items

### Adding a Skill

1. Create a folder in `skills/` (e.g., `my-skill/`)
2. Add a `SKILL.md` file with your skill definition
3. Run `./scripts/claude_sync.sh` or `./scripts/opencode_sync.sh`
4. You'll be prompted to confirm before syncing

### Adding a Rule

1. Create a `.md` file in `rules/` (e.g., `my-rule.md`)
2. Write your rule content
3. Run `./scripts/claude_sync.sh` or `./scripts/opencode_sync.sh`
4. You'll be prompted to confirm before syncing

### Adding Settings

1. Place configuration files in `settings/`
   - `settings.json` for Claude Code settings
   - Shell scripts like `statusline-command.sh`
2. Run `./scripts/claude_sync.sh`
3. You'll be prompted to confirm before syncing

## Workflow

1. **Pull latest changes** from this repo:
   ```bash
   git pull origin main
   ```

2. **Sync to your local config**:
   ```bash
   ./scripts/claude_sync.sh      # For Claude Code
   # or
   ./scripts/opencode_sync.sh    # For OpenCode
   ```

3. **Restart Claude Code or OpenCode** to reload the configuration

4. **Contribute back** by adding new skills, rules, or settings and opening a PR

## Other Recommended Skills & Rules

- [obra/superpowers](https://github.com/obra/superpowers) - A complete software development methodology for coding agents

## Support

For more information about Claude Code configuration:
- `/help` - In Claude Code for built-in help
- [Claude Code Documentation](https://github.com/anthropics/claude-code)
