# Google Docs MCP (local) — setup & reinstall notes

Local MCP server giving Claude Code full Google Docs/Drive API access using
**your own** Google OAuth credentials. Unlike the claude.ai-hosted Google
connector (and cowork), this supports editing a specific paragraph / section,
find-replace, insert-at-anchor — plus reading Drive files with your permissions.

- Server: https://github.com/dbuxton/google-docs-mcp  (v3.3.1, stdio, Python via uvx)
- 14 tools: docs_get, docs_list, docs_create, docs_append, docs_search_replace,
  docs_batch_replace, docs_insert_after, docs_insert_before,
  docs_delete_paragraph, docs_add_comment, docs_reply_to_comment,
  docs_resolve_comment, docs_delete_comment, docs_read_comments.
- Status 2026-05-30: server starts, lists tools, OAuth OK. End-to-end write
  test best done in-session via the mcp__google-docs__* tools after a restart
  (transparent in transcript) rather than an out-of-band script.

## What lives where

- Credentials + token: `~/.google-docs-mcp/` (OUTSIDE this repo, never committed)
  - `credentials.json` — OAuth Desktop client (chmod 600)
  - `token.json`       — authorized token (chmod 600)
  - `run-auth.sh`      — one-shot (re)auth helper (copy kept here as google-docs-run-auth.sh)
- MCP registration: `~/.claude.json` (user scope) — NOT git-tracked (contains
  chat history). Registered by editing the file's top-level `mcpServers` key:
  ```json
  "google-docs": {
    "type": "stdio",
    "command": "uvx",
    "args": ["--from", "git+https://github.com/dbuxton/google-docs-mcp", "google-docs-mcp"],
    "env": {
      "GOOGLE_DOCS_MCP_CREDENTIALS": "/Users/leeheng/.google-docs-mcp/credentials.json",
      "GOOGLE_DOCS_MCP_TOKEN": "/Users/leeheng/.google-docs-mcp/token.json"
    }
  }
  ```
  (Use absolute paths in the real file — ~ is not expanded there.)

## Gotchas hit during setup (so future-me doesn't repeat them)

- `claude mcp add` was NOT used: this machine has `alias claude='claude --remote-control'`,
  so calling `claude ...` from inside a Claude Code session spawns a nested
  session and treats args as a prompt. Edit `~/.claude.json` directly instead.
- macOS has no `timeout` (GNU). Use a background process + `sleep` + `kill`,
  or `perl -e 'alarm N; exec @ARGV'`.
- Unverified OAuth app → must add your gmail under **Test users** or auth
  returns `Error 403: access_denied`. Client ID identifies the *app*; the test
  user authorizes the *person* — both are required.
- Docs/Drive API are quota-based and **free**; no billing/credit card. If any
  screen demands a billing account, you took a wrong turn.
- MCP servers load at session start. After editing ~/.claude.json, restart
  Claude Code for the tools to appear (mcp__google-docs__*).

## Reinstall on a new machine

1. Google Cloud Console (console.cloud.google.com):
   - Project: `claude-docs-mcp-497919` (or new)
   - Enable **Google Docs API** + **Google Drive API**
   - OAuth consent screen → External → add `leeheng86@gmail.com` to **Test users**
   - Credentials → Create OAuth client ID → **Desktop app** → download JSON
2. Place creds:
   `mkdir -p ~/.google-docs-mcp && mv ~/Downloads/client_secret_*.json ~/.google-docs-mcp/credentials.json && chmod 600 ~/.google-docs-mcp/credentials.json`
3. Authorize (opens browser; sign in, Advanced → proceed to claude-docs-mcp → allow):
   `bash ~/.rc/claude/google-docs-run-auth.sh`
4. Register the server (one line):
   `bash ~/.rc/claude/install-google-docs-mcp.sh`
5. Restart Claude Code; the `google-docs` MCP tools should appear.

Prereqs: `uv`/`uvx` (already at ~/.local/bin), python3.
