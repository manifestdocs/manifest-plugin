#!/bin/bash
# Check if the Manifest server is reachable.
# Used as a Setup hook to guide new users through launching the app.

if curl -sf http://localhost:17010/health > /dev/null 2>&1; then
  echo "Manifest server is running"
  exit 0
fi

cat <<'MSG'
Manifest server is not reachable at http://localhost:17010.

Launch the Manifest desktop app, or install the server with Homebrew:

  brew install rocket-tycoon/tap/manifest

Then restart Claude Code for the MCP tools to become available.
MSG

# Exit 0 so the plugin still loads — skills remain available for discovery.
exit 0
