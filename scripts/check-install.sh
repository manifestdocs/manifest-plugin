#!/bin/bash
# Check if the manifest binary is installed.
# Used as a Setup hook to guide new users through installation.

if command -v manifest &> /dev/null; then
  echo "manifest $(manifest --version 2>/dev/null || echo '(installed)')"
  exit 0
fi

cat <<'MSG'
Manifest server is not installed.

Install it with Homebrew:

  brew install rocket-tycoon/tap/manifest

Then restart Claude Code for the MCP tools to become available.
MSG

# Exit 0 so the plugin still loads — skills remain available for discovery.
exit 0
