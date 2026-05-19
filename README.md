# popcorn

Grab some popcorn while your CLI agent works.

A Claude Code plugin that **auto-plays the open YouTube tab while the agent is working** and **pauses it the moment the agent needs your input** — then refocuses your terminal so you don't miss the prompt. Designed to extend to TikTok / Instagram and other CLI agents (Codex, etc.) later.

macOS only. Works with Google Chrome (default), Arc, or Safari.

## How it works

| Event | Hook | Action |
|---|---|---|
| You submit a prompt | `UserPromptSubmit` | Remember the frontmost app (your terminal), switch focus to the YouTube tab, raise its window, and resume playback |
| Claude finishes responding | `Stop` | Pause the YouTube tab and re-activate the terminal |
| Claude asks for input (e.g. permission prompt) | `Notification` | Same as `Stop` |

There's no playlist or URL config — just keep a YouTube tab open in your browser and the plugin controls play/pause from there. "Always resume last video" comes for free because the video itself remembers its position.

## Install

Three slash commands inside Claude Code:

```text
/plugin marketplace add callmejustdodo/popcorn
/plugin install popcorn@popcorn
/reload-plugins
```

Claude Code clones the repo into `~/.claude/plugins/marketplaces/popcorn/` for you — no manual `git clone` needed.

### From a local clone (only if you want to hack on it)

```bash
git clone https://github.com/callmejustdodo/popcorn.git
cd popcorn
./install.sh                                  # validates JSON + AppleScript syntax
# then inside Claude Code:
#   /plugin marketplace add /path/to/popcorn
#   /plugin install popcorn@popcorn
#   /reload-plugins
```

Note that `/plugin install` *copies* the repo into `~/.claude/plugins/cache/popcorn/popcorn/<version>/`, so edits to your clone don't reach the running plugin until you bump the version in `plugin.json` + `marketplace.json` and reinstall (or `cp` your edits into the cache manually).

### One-time browser setup

The plugin pauses/plays by injecting a one-liner into the YouTube tab via AppleScript, which Chrome/Safari block by default. Enable it once per browser:

- **Chrome / Arc** — `View → Developer → Allow JavaScript from Apple Events` (you'll get a one-time confirmation prompt). Restart the browser.
- **Safari** — `Safari → Settings → Advanced → Show Develop menu`, then `Develop → Allow JavaScript from Apple Events`.

The first time the AppleScript actually pokes a tab, the browser shows a second "Allow this app to control Chrome?" prompt — click Allow there too.

## Usage

1. Open any YouTube video or Short in your browser. (Or `/popcorn:watch <url>` once the plugin is loaded.)
2. Submit a prompt to Claude — the video auto-plays and Chrome jumps to the front.
3. The instant Claude finishes or asks for permission, the video pauses and your terminal jumps back to the front.

Shorts work too — the selector picks the largest *visible* `<video>` element, so the hidden preload slots don't get controlled by mistake.

## Configuration

Environment variables (set in your shell rc):

| Var | Default | What it does |
|---|---|---|
| `CLAUDE_YOUTUBE_BROWSER` | `Google Chrome` | App name to control. Try `"Safari"`, `"Arc"`, `"Brave Browser"`, or `"Microsoft Edge"`. |

Kill switch (no restart needed):

```bash
touch ~/.claude/.popcorn-disabled   # disable
rm    ~/.claude/.popcorn-disabled   # re-enable
```

Or run `/popcorn:watch-toggle` from inside Claude Code.

## Slash commands

- `/popcorn:watch <youtube-url>` — opens the URL in your configured browser.
- `/popcorn:watch-toggle` — flip the kill switch.

## Files

```
.claude-plugin/plugin.json       plugin manifest
.claude-plugin/marketplace.json  self-hosting marketplace manifest
hooks/hooks.json                 registers UserPromptSubmit / Stop / Notification hooks
scripts/on-prompt.sh             saves frontmost app, plays YouTube, focuses Chrome
scripts/on-stop.sh               pauses YouTube, restores frontmost app
scripts/play.applescript         finds the largest visible YouTube <video> and resumes
scripts/pause.applescript        finds the largest visible YouTube <video> and pauses
commands/watch.md                /popcorn:watch slash command
commands/watch-toggle.md         /popcorn:watch-toggle slash command
install.sh                       repo validator + install-instructions printer
```

## Troubleshooting

- **Nothing happens** — the most common cause is forgetting the "Allow JavaScript from Apple Events" setting. Verify by running the script manually: `osascript scripts/pause.applescript "Google Chrome"`. If your video doesn't actually pause, the setting isn't applied yet.
- **The wrong app gets focused after pause** — the plugin saves whichever app was frontmost the instant you press Enter. If you alt-tab to the browser before submitting, the browser is what it'll remember. Hit Enter from your terminal.
- **Multiple YouTube tabs open** — the plugin controls the first one it finds. Close the ones you don't want auto-controlled.
- **Shorts don't pause/play** — fixed in v0.2.0 (the plugin now picks the largest *visible* `<video>` element so the hidden preload slots are ignored). Make sure you're on at least that version.

## Roadmap

- TikTok / Instagram Reels support (same AppleScript-into-browser-tab pattern, different selectors)
- Codex CLI adapter (Claude Code's hook protocol doesn't apply; needs a pty / stdout watcher)
- Multi-tab round-robin so you don't end up on the same Short every prompt

## License

MIT
