#!/bin/bash
# Check if the Manifest server is installed and running.
# Used as a Setup hook — runs when the plugin loads in Claude Code.
#
# Flow:
# 1. If server is already running → done
# 2. If `manifest` binary exists → start it
# 3. If Homebrew is available → install via brew, then start
# 4. Otherwise → print manual install instructions

SERVER_URL="http://localhost:17010"
BREW_FORMULA="manifestdocs/tap/manifest"

# 1. Server already running?
if curl -sf "$SERVER_URL/health" > /dev/null 2>&1; then
  exit 0
fi

# Helper: start the server in the background and verify it's up.
start_server() {
  nohup manifest serve > /dev/null 2>&1 &
  sleep 2
  curl -sf "$SERVER_URL/health" > /dev/null 2>&1
}

# 2. Binary installed but not running?
if command -v manifest > /dev/null 2>&1; then
  echo "Starting Manifest server..."
  if start_server; then
    echo "Manifest server started."
    exit 0
  fi
  echo "Manifest server failed to start. Run 'manifest serve' manually to see errors."
  exit 0
fi

# 3. Homebrew available? Install and start.
if command -v brew > /dev/null 2>&1; then
  echo "Installing Manifest via Homebrew..."
  if brew install "$BREW_FORMULA" 2>&1; then
    echo "Starting Manifest server..."
    if start_server; then
      echo "Manifest installed and running."
      exit 0
    fi
    echo "Installed but server failed to start. Run 'manifest serve' to see errors."
    exit 0
  else
    echo "Homebrew install failed. Install manually:"
    echo "  brew install $BREW_FORMULA"
    exit 0
  fi
fi

# 4. No brew — manual instructions.
cat <<'MSG'
Manifest server is not installed.

Install with Homebrew:

  brew install manifestdocs/tap/manifest
  manifest serve

Or download from: https://github.com/manifestdocs/manifest/releases

Then restart Claude Code for the MCP tools to become available.
MSG

exit 0
