#!/bin/bash
# Fires when the user submits a prompt. Plays the open YouTube tab.
# Silently no-ops if no YouTube tab is open or AppleScript is unavailable.

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BROWSER="${CLAUDE_YOUTUBE_BROWSER:-Google Chrome}"
STATE_DIR="${TMPDIR:-/tmp}"
FRONT_APP_FILE="$STATE_DIR/claude-youtube-frontapp"
DISABLED_FILE="$HOME/.claude/.youtube-watcher-disabled"

[ -f "$DISABLED_FILE" ] && exit 0
command -v osascript >/dev/null 2>&1 || exit 0

# Remember which app was frontmost (usually the terminal) so we can refocus later.
osascript -e 'tell application "System Events" to name of first application process whose frontmost is true' \
  > "$FRONT_APP_FILE" 2>/dev/null || true

# Resume any YouTube tab that's currently paused.
osascript "$PLUGIN_DIR/scripts/play.applescript" "$BROWSER" >/dev/null 2>&1 || true

exit 0
