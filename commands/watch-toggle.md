---
description: Temporarily disable or re-enable the youtube-watcher hooks
allowed-tools: Bash
---

Toggle the youtube-watcher plugin by creating or removing the kill-switch file:

```
if [ -f "$HOME/.claude/.youtube-watcher-disabled" ]; then
  rm "$HOME/.claude/.youtube-watcher-disabled"
  echo "youtube-watcher: ENABLED"
else
  touch "$HOME/.claude/.youtube-watcher-disabled"
  echo "youtube-watcher: DISABLED"
fi
```

Run that and report the new state.
