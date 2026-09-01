#!/bin/sh
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
TOTAL=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

TOTAL_K=$(echo "$TOTAL" | awk '{printf "%.0fk", $1/1000}')
INPUT_K=$(echo "$INPUT_TOKENS" | awk '{printf "%.1fk", $1/1000}')
COST_FMT=$(printf '$%.2f' "$COST")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

line1="📁 ${DIR##*/}"
if [ -n "$BRANCH" ]; then
  line1="$line1 | 🌿 $BRANCH"
fi
echo "$line1"

echo "model: ${MODEL} | context: ${PCT}% | spent: ${COST_FMT}"
