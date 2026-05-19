#!/bin/bash
# Installer for youtube-watcher.
#
# Claude Code loads plugins through marketplaces, so this repo includes a
# self-hosting `marketplace.json`. Run this script first to validate the
# repo, then finish the install with the two slash commands printed at
# the end (they have to be run inside Claude Code itself).

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Sanity check the manifest files
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json hooks/hooks.json; do
  if ! python3 -c "import json; json.load(open('$REPO_DIR/$f'))" >/dev/null 2>&1; then
    echo "Error: invalid JSON at $f" >&2
    exit 1
  fi
done

# Compile AppleScripts to catch syntax errors before Claude Code does
for f in scripts/play.applescript scripts/pause.applescript; do
  if ! osacompile -o /tmp/.youtube-watcher-syntax.scpt "$REPO_DIR/$f" 2>/dev/null; then
    echo "Error: AppleScript syntax error in $f" >&2
    rm -f /tmp/.youtube-watcher-syntax.scpt
    exit 1
  fi
done
rm -f /tmp/.youtube-watcher-syntax.scpt

# Make shell hook scripts executable
chmod +x "$REPO_DIR"/scripts/*.sh

# Clean up any stale symlink from previous installs (no longer needed)
STALE_LINK="$HOME/.claude/plugins/youtube-watcher"
if [ -L "$STALE_LINK" ]; then
  rm "$STALE_LINK"
fi

cat <<EOF
youtube-watcher repo validated at: $REPO_DIR

Finish the install inside Claude Code (these are slash commands, not shell):

    /plugin marketplace add $REPO_DIR
    /plugin install youtube-watcher@claude-youtube-watcher

Then once per browser, enable JS-from-AppleEvents:
    Chrome / Arc: View > Developer > 'Allow JavaScript from Apple Events'
    Safari:       enable Develop menu, then Develop > 'Allow JavaScript from Apple Events'

Restart Claude Code after installing so the hooks are registered.

To target a non-Chrome browser, set in your shell rc:
    export CLAUDE_YOUTUBE_BROWSER='Safari'   # or 'Arc', 'Brave Browser', ...
EOF
