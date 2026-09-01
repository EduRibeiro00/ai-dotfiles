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

Run the sync script to copy skills, rules, and settings:

```bash
./scripts/claude_sync.sh      # For Claude Code
# or
./scripts/opencode_sync.sh    # For OpenCode
```

**What it does:**
- Syncs skills from `skills/` to `~/.claude/skills/`
- Syncs rules from `rules/` to `~/.claude/rules/`
- Syncs settings from `settings/` to `~/.claude/`
- Shows an `Overwrite? (y/N):` prompt for each item that already exists
- Only copies what you confirm

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

## Other Recommended Skills & Rules

- [obra/superpowers](https://github.com/obra/superpowers) - A complete software development methodology for coding agents
