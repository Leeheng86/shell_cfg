#!/usr/bin/env bash
# Claude Code status line — mirrors the bash PS1 from ~/.rc/common.sh
# PS1 was: " \# [\[\e[32;1m\]\w\[\e[0m\]]\$"
# Trailing "$" is omitted as required.

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Format the PS1-style prefix: " # [<cwd in bold green>]"
prefix=$(printf " # [\033[32;1m%s\033[0m]" "$cwd")

# Append model name
suffix=$(printf " | %s" "$model")

# Append context usage if available
if [ -n "$used" ]; then
    used_int=$(printf '%.0f' "$used")
    suffix=$(printf "%s | ctx:%s%%" "$suffix" "$used_int")
fi

printf "%s%s" "$prefix" "$suffix"
