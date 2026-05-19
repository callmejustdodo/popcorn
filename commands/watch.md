---
description: Open a YouTube URL in your browser so the watcher plugin can auto play/pause it
argument-hint: <youtube-url>
allowed-tools: Bash
---

Open the YouTube URL `$ARGUMENTS` in the configured browser (defaults to Google Chrome,
override with the `CLAUDE_YOUTUBE_BROWSER` env var) by running:

```
open -a "${CLAUDE_YOUTUBE_BROWSER:-Google Chrome}" "$ARGUMENTS"
```

After opening, reply with one short sentence confirming the video is loaded. From now on the
youtube-watcher plugin will auto-resume this tab whenever I submit a prompt and pause it the
moment you finish or need my input.
