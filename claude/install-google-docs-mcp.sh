#!/usr/bin/env bash
# One-line installer for the local Google Docs MCP server (Claude Code, user scope).
#
#   bash ~/.rc/claude/install-google-docs-mcp.sh
#
# Idempotent: re-running just rewrites the google-docs entry in ~/.claude.json.
# Prereqs: uvx (https://docs.astral.sh/uv/), python3, and OAuth creds already
# placed + authorized (see google-docs-mcp-setup.md steps 1-3).
set -euo pipefail

CRED="$HOME/.google-docs-mcp/credentials.json"
TOKEN="$HOME/.google-docs-mcp/token.json"
CFG="$HOME/.claude.json"

command -v uvx >/dev/null || { echo "ERROR: uvx not found. Install uv first: https://docs.astral.sh/uv/"; exit 1; }
[ -f "$CRED" ]  || { echo "ERROR: $CRED missing. See google-docs-mcp-setup.md steps 1-2."; exit 1; }
[ -f "$TOKEN" ] || { echo "ERROR: $TOKEN missing. Run google-docs-run-auth.sh (step 3) first."; exit 1; }
[ -f "$CFG" ]   || echo '{}' > "$CFG"

cp "$CFG" "$CFG.bak-$(date +%Y%m%d-%H%M%S)"

CRED="$CRED" TOKEN="$TOKEN" CFG="$CFG" python3 - <<'PY'
import json, os
cfg = os.environ["CFG"]
with open(cfg) as f:
    d = json.load(f)
d.setdefault("mcpServers", {})["google-docs"] = {
    "type": "stdio",
    "command": "uvx",
    "args": ["--from", "git+https://github.com/dbuxton/google-docs-mcp", "google-docs-mcp"],
    "env": {
        "GOOGLE_DOCS_MCP_CREDENTIALS": os.environ["CRED"],
        "GOOGLE_DOCS_MCP_TOKEN": os.environ["TOKEN"],
    },
}
with open(cfg, "w") as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
print("Registered 'google-docs' MCP server in", cfg)
PY

echo "Done. Restart Claude Code; tools appear as mcp__google-docs__*"
