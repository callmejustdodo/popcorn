---
description: Open a YouTube / TikTok / Instagram URL in your browser so popcorn can auto play/pause it
argument-hint: <url>
allowed-tools: Bash
---

Open `$ARGUMENTS` in the popcorn-configured browser by running:

```bash
# resolve the configured browser (env var > config file > default Chrome)
BROWSER="${POPCORN_BROWSER:-$(cat "$HOME/.claude/.popcorn-browser" 2>/dev/null)}"
BROWSER="${BROWSER:-Google Chrome}"
open -a "$BROWSER" "$ARGUMENTS"
```

After opening, reply with one short sentence confirming the page is loaded. From now on popcorn will auto-resume this tab whenever I submit a prompt and pause it the moment you finish or need my input.
