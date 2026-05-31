#!/usr/bin/env bash
# One-time OAuth authorization for google-docs-mcp.
# Opens a browser; sign in as leeheng86@gmail.com and approve Docs/Drive access.
set -euo pipefail

export UV_NO_PROGRESS=1
CRED="$HOME/.google-docs-mcp/credentials.json"

uvx --from git+https://github.com/dbuxton/google-docs-mcp \
    google-docs-mcp-auth --credentials "$CRED"
