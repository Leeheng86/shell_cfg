#!/usr/bin/env bash
# Claude Code status line — mirrors the bash PS1 from ~/.rc/common.sh
# PS1 was: " \# [\[\e[32;1m\]\w\[\e[0m\]]\$"
# Trailing "$" is omitted as required.

input=$(cat)

cwd=$(echo "$input"    | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input"  | jq -r '.model.display_name')

# --- git branch (optional) ---
branch=$(git -C "$cwd" branch --show-current 2>/dev/null)

# --- context window ---
used_pct=$(echo "$input"    | jq -r '.context_window.used_percentage // empty')
# Raw tokens currently in context: sum of fields inside current_usage (input + cache creation + cache read)
used_tok=$(echo "$input"    | jq -r '
  (.context_window.current_usage // null)
  | if . == null then empty
    else ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0))
    end')

# --- billing / rate limits (subscription plan) ---
five_pct=$(echo "$input"  | jq -r '.rate_limits.five_hour.used_percentage  // empty')
week_pct=$(echo "$input"  | jq -r '.rate_limits.seven_day.used_percentage  // empty')

# ----------------------------------------------------------------
# Line 1:  # [<bold-green cwd>] (<branch>)  |  <model>
# ----------------------------------------------------------------
line1=$(printf " # [\033[32;1m%s\033[0m]" "$cwd")

if [ -n "$branch" ]; then
    line1=$(printf "%s \033[33m(%s)\033[0m" "$line1" "$branch")
fi

line1=$(printf "%s | %s" "$line1" "$model")

# ----------------------------------------------------------------
# Line 2:  ctx: <tokens> (<pct>%)  |  5h: <pct>%  7d: <pct>%
# ----------------------------------------------------------------
line2=""

# Context usage segment
if [ -n "$used_tok" ] && [ -n "$used_pct" ]; then
    used_pct_int=$(printf '%.0f' "$used_pct")
    # Format token count with k/M suffix for readability
    if [ "$used_tok" -ge 1000000 ] 2>/dev/null; then
        tok_fmt=$(awk "BEGIN{printf \"%.1fM\", $used_tok/1000000}")
    elif [ "$used_tok" -ge 1000 ] 2>/dev/null; then
        tok_fmt=$(awk "BEGIN{printf \"%.0fk\", $used_tok/1000}")
    else
        tok_fmt="$used_tok"
    fi
    line2=$(printf "ctx: %s (%s%%)" "$tok_fmt" "$used_pct_int")
elif [ -n "$used_pct" ]; then
    used_pct_int=$(printf '%.0f' "$used_pct")
    line2=$(printf "ctx: %s%%" "$used_pct_int")
fi

# Rate limit segment (subscription plan only — fields absent for pay-as-you-go)
rate_seg=""
if [ -n "$five_pct" ]; then
    five_int=$(printf '%.0f' "$five_pct")
    rate_seg=$(printf "5h:%s%%" "$five_int")
fi
if [ -n "$week_pct" ]; then
    week_int=$(printf '%.0f' "$week_pct")
    if [ -n "$rate_seg" ]; then
        rate_seg=$(printf "%s 7d:%s%%" "$rate_seg" "$week_int")
    else
        rate_seg=$(printf "7d:%s%%" "$week_int")
    fi
fi

if [ -n "$rate_seg" ]; then
    if [ -n "$line2" ]; then
        line2=$(printf "%s | %s" "$line2" "$rate_seg")
    else
        line2="$rate_seg"
    fi
fi

# ----------------------------------------------------------------
# Output: two lines when line2 has content, one line otherwise
# ----------------------------------------------------------------
if [ -n "$line2" ]; then
    printf "%s\n %s" "$line1" "$line2"
else
    printf "%s" "$line1"
fi
