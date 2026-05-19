#!/bin/bash
# One-shot installer: symlinks this repo into ~/.claude/plugins/youtube-watcher
# so Claude Code picks up the hooks. Re-running is safe.

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$HOME/.claude/plugins/youtube-watcher"

mkdir -p "$HOME/.claude/plugins"

if [ -L "$TARGET" ]; then
  echo "Removing existing symlink: $TARGET"
  rm "$TARGET"
elif [ -e "$TARGET" ]; then
  echo "Error: $TARGET exists and is not a symlink. Move or delete it first." >&2
  exit 1
fi

ln -s "$REPO_DIR" "$TARGET"
chmod +x "$REPO_DIR"/scripts/*.sh

echo "Installed: $TARGET -> $REPO_DIR"
echo
echo "Next steps:"
echo "  1) Enable JS-from-AppleEvents in your browser (one-time):"
echo "       Chrome/Arc: View > Developer > 'Allow JavaScript from Apple Events'"
echo "       Safari:     enable Develop menu, then Develop > 'Allow JavaScript from Apple Events'"
echo "  2) Restart Claude Code so it loads the new plugin hooks."
echo "  3) Open a YouTube video in your browser (or run '/watch <url>')."
echo
echo "Override the browser via env var, e.g.:  export CLAUDE_YOUTUBE_BROWSER='Safari'"
