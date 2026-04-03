#!/usr/bin/env bash
# Claude Code status line — single line format:
#   model | branch | ctx tokens (%) | rate limits | path

input=$(cat)

cwd=$(echo "$input"   | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name')

# --- git branch (optional) ---
branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)

# --- context window ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
used_tok=$(echo "$input" | jq -r '
  (.context_window.current_usage // null)
  | if . == null then empty
    else ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0))
    end')

# --- rate limits (subscription plan only) ---
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage  // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage  // empty')

# ----------------------------------------------------------------
# Build ordered segments; collect non-empty ones into an array
# ----------------------------------------------------------------
segments=()

# 1. model
[ -n "$model" ] && segments+=("$model")

# 2. branch
[ -n "$branch" ] && segments+=("$branch")

# 3. ctx tokens (%)
if [ -n "$used_tok" ] && [ -n "$used_pct" ]; then
    used_pct_int=$(printf '%.0f' "$used_pct")
    if [ "$used_tok" -ge 1000000 ] 2>/dev/null; then
        tok_fmt=$(awk "BEGIN{printf \"%.1fM\", $used_tok/1000000}")
    elif [ "$used_tok" -ge 1000 ] 2>/dev/null; then
        tok_fmt=$(awk "BEGIN{printf \"%.0fk\", $used_tok/1000}")
    else
        tok_fmt="$used_tok"
    fi
    segments+=("${tok_fmt} (${used_pct_int}%)")
fi

# 4. rate limits
rate_seg=""
if [ -n "$five_pct" ]; then
    five_int=$(printf '%.0f' "$five_pct")
    rate_seg="5h:${five_int}%"
fi
if [ -n "$week_pct" ]; then
    week_int=$(printf '%.0f' "$week_pct")
    rate_seg="${rate_seg:+${rate_seg} }7d:${week_int}%"
fi
[ -n "$rate_seg" ] && segments+=("$rate_seg")

# 5. path — bold green
path_seg=$(printf "\033[32;1m%s\033[0m" "$cwd")
segments+=("$path_seg")

# ----------------------------------------------------------------
# Join with " | " and print — no trailing newline
# ----------------------------------------------------------------
out=""
for seg in "${segments[@]}"; do
    if [ -z "$out" ]; then
        out="$seg"
    else
        out="${out} | ${seg}"
    fi
done

printf "%s" "$out"
