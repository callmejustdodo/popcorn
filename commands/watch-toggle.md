---
description: Temporarily disable or re-enable the popcorn hooks
allowed-tools: Bash
---

Toggle the popcorn plugin by creating or removing the kill-switch file:

```
if [ -f "$HOME/.claude/.popcorn-disabled" ]; then
  rm "$HOME/.claude/.popcorn-disabled"
  echo "popcorn: ENABLED"
else
  touch "$HOME/.claude/.popcorn-disabled"
  echo "popcorn: DISABLED"
fi
```

Run that and report the new state.
