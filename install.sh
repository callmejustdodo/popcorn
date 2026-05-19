#!/bin/bash
# Installer for popcorn.
#
# Claude Code loads plugins through marketplaces, so this repo includes a
# self-hosting `marketplace.json`. Run this script first to validate the
# repo, then finish the install with the slash commands printed at the end
# (they have to be run inside Claude Code itself).

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
  if ! osacompile -o /tmp/.popcorn-syntax.scpt "$REPO_DIR/$f" 2>/dev/null; then
    echo "Error: AppleScript syntax error in $f" >&2
    rm -f /tmp/.popcorn-syntax.scpt
    exit 1
  fi
done
rm -f /tmp/.popcorn-syntax.scpt

# Make shell hook scripts executable
chmod +x "$REPO_DIR"/scripts/*.sh

# Clean up legacy symlink from very early installs (no longer needed)
for stale in "$HOME/.claude/plugins/youtube-watcher" "$HOME/.claude/plugins/popcorn"; do
  if [ -L "$stale" ]; then
    rm "$stale"
  fi
done

cat <<EOF
popcorn repo validated at: $REPO_DIR

Finish the install inside Claude Code (these are slash commands, not shell).

If upgrading from an older youtube-watcher install, run these first:
    /plugin uninstall youtube-watcher@claude-youtube-watcher
    /plugin marketplace remove claude-youtube-watcher

Then install popcorn:
    /plugin marketplace add $REPO_DIR
    /plugin install popcorn@popcorn
    /reload-plugins

Then once per browser, enable JS-from-AppleEvents:
    Chrome / Arc: View > Developer > 'Allow JavaScript from Apple Events'
    Safari:       enable Develop menu, then Develop > 'Allow JavaScript from Apple Events'

To target a non-Chrome browser, set in your shell rc:
    export CLAUDE_YOUTUBE_BROWSER='Safari'   # or 'Arc', 'Brave Browser', ...
EOF
