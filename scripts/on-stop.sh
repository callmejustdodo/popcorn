#!/bin/bash
# Fires when Claude finishes responding OR needs the user's attention.
# Pauses the YouTube tab and refocuses the terminal that was active when the prompt was submitted.

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BROWSER_CONFIG="$HOME/.claude/.popcorn-browser"
if [ -n "$POPCORN_BROWSER" ]; then
  BROWSER="$POPCORN_BROWSER"
elif [ -f "$BROWSER_CONFIG" ]; then
  BROWSER=$(cat "$BROWSER_CONFIG" 2>/dev/null)
fi
BROWSER="${BROWSER:-Google Chrome}"
STATE_DIR="${TMPDIR:-/tmp}"
FRONT_APP_FILE="$STATE_DIR/popcorn-frontapp"
DISABLED_FILE="$HOME/.claude/.popcorn-disabled"

[ -f "$DISABLED_FILE" ] && exit 0
command -v osascript >/dev/null 2>&1 || exit 0

osascript "$PLUGIN_DIR/scripts/pause.applescript" "$BROWSER" >/dev/null 2>&1 || true

if [ -f "$FRONT_APP_FILE" ]; then
  FRONT_APP=$(cat "$FRONT_APP_FILE" 2>/dev/null)
  if [ -n "$FRONT_APP" ] && [ "$FRONT_APP" != "$BROWSER" ]; then
    osascript -e "tell application \"$FRONT_APP\" to activate" >/dev/null 2>&1 || true
  fi
fi

exit 0
