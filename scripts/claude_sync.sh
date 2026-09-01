#!/bin/bash

# Claude Code Sync Script
# Syncs skills, rules, and settings to Claude Code configuration directory

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$( dirname "$SCRIPT_DIR" )"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

printf "\n${BLUE}=== Claude Code Sync ===${NC}\n\n"

CONFIG_DIR="$HOME/.claude"

printf "Claude Config Directory: ${BLUE}%s${NC}\n\n" "$CONFIG_DIR"

mkdir -p "$CONFIG_DIR"

# Function to safely copy individual items
sync_items() {
    local source_dir=$1
    local dest_dir=$2
    local item_type=$3

    if [ ! -d "$source_dir" ]; then
        printf "${RED}✗ Source not found: %s${NC}\n" "$source_dir"
        return 1
    fi

    mkdir -p "$dest_dir"

    # Check if source has items
    if [ ! "$(ls -A "$source_dir" 2>/dev/null)" ]; then
        printf "${YELLOW}ℹ No %s to sync${NC}\n" "$item_type"
        return 0
    fi

    # Iterate through each item in source
    for source_item in "$source_dir"/*; do
        if [ -e "$source_item" ]; then
            item_name=$(basename "$source_item")
            dest_item="$dest_dir/$item_name"

            # Check if destination item exists
            if [ -e "$dest_item" ]; then
                printf "${YELLOW}⚠ %s already exists:${NC}\n" "$item_name"
                printf "  %s${NC}\n" "$dest_item"
                printf "${YELLOW}Overwrite? (y/N):${NC} "
                read -n 1 -r
                printf "\n"
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    printf "${YELLOW}⊘ Skipped %s${NC}\n\n" "$item_name"
                    continue
                fi
                printf "${GREEN}Replacing %s...${NC}\n" "$item_name"
            fi

            # Copy the item
            if [ -d "$source_item" ]; then
                rm -rf "$dest_item" 2>/dev/null || true
                cp -r "$source_item" "$dest_item"
            else
                cp "$source_item" "$dest_item"
            fi

            printf "${GREEN}✓ Synced %s${NC}\n\n" "$item_name"
        fi
    done
}

# Sync skills
printf "${BLUE}=== Skills${NC}\n"
sync_items "$REPO_DIR/skills" "$CONFIG_DIR/skills" "skills"
printf "\n"

# Sync rules
printf "${BLUE}=== Rules${NC}\n"
sync_items "$REPO_DIR/rules" "$CONFIG_DIR/rules" "rules"
printf "\n"

# Sync settings (individual files)
printf "${BLUE}=== Settings${NC}\n"
if [ -d "$REPO_DIR/settings" ] && [ "$(ls -A "$REPO_DIR/settings" 2>/dev/null)" ]; then
    for file in "$REPO_DIR/settings"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            dest_file="$CONFIG_DIR/$filename"

            if [ -f "$dest_file" ]; then
                printf "${YELLOW}⚠ %s already exists:${NC}\n" "$filename"
                printf "  %s${NC}\n" "$dest_file"
                printf "${YELLOW}Overwrite? (y/N):${NC} "
                read -n 1 -r
                printf "\n"
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    printf "${YELLOW}⊘ Skipped %s${NC}\n\n" "$filename"
                    continue
                fi
                printf "${GREEN}Replacing %s...${NC}\n" "$filename"
            fi

            cp "$file" "$dest_file"
            printf "${GREEN}✓ Synced %s${NC}\n\n" "$filename"
        fi
    done
else
    printf "${YELLOW}ℹ No settings to sync${NC}\n"
fi

printf "\n${GREEN}=== Sync Complete ===${NC}\n"
printf "Config directory: ${BLUE}%s${NC}\n\n" "$CONFIG_DIR"
printf "${YELLOW}Next: Restart Claude Code to reload the configuration${NC}\n"
