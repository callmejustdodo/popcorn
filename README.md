# claude-youtube-watcher

A Claude Code plugin that **plays YouTube while Claude is working** and **pauses it the moment Claude needs your input** — then refocuses your terminal so you don't miss the prompt.

macOS only. Works with Google Chrome (default), Arc, or Safari.

## How it works

| Event | Hook | Action |
|---|---|---|
| You submit a prompt | `UserPromptSubmit` | Remember the frontmost app (your terminal) and play any open YouTube tab |
| Claude finishes responding | `Stop` | Pause the YouTube tab, re-activate the terminal |
| Claude asks for input (e.g. permission prompt) | `Notification` | Same as `Stop` |

There's no playlist or URL config — just keep a YouTube tab open in your browser and the plugin controls play/pause from there. "Always resume last video" comes for free because the video itself remembers its position.

## Install

```bash
git clone <this-repo> ~/dev/claude-youtube-watcher    # or wherever
cd ~/dev/claude-youtube-watcher
./install.sh
```

The installer symlinks the repo into `~/.claude/plugins/youtube-watcher` and makes the hook scripts executable.

### One-time browser setup

The plugin pauses/plays by injecting a one-liner into the YouTube tab via AppleScript, which Chrome/Safari block by default. Enable it once per browser:

- **Chrome / Arc** — `View → Developer → Allow JavaScript from Apple Events` (you'll get a one-time confirmation prompt). Restart the browser.
- **Safari** — `Safari → Settings → Advanced → Show Develop menu`, then `Develop → Allow JavaScript from Apple Events`.

Restart Claude Code after installing so it picks up the new hooks.

## Usage

1. Open any YouTube video in your browser. (Or `/watch <url>` once the plugin is loaded.)
2. Submit a prompt to Claude — the video auto-plays.
3. The instant Claude finishes or asks for permission, the video pauses and your terminal jumps back to the front.

## Configuration

Environment variables (set in your shell rc):

| Var | Default | What it does |
|---|---|---|
| `CLAUDE_YOUTUBE_BROWSER` | `Google Chrome` | App name to control. Try `"Safari"` or `"Arc"`. |

Kill switch (no restart needed):

```bash
touch ~/.claude/.youtube-watcher-disabled   # disable
rm    ~/.claude/.youtube-watcher-disabled   # re-enable
```

Or run `/watch-toggle` from inside Claude Code.

## Slash commands

- `/watch <youtube-url>` — opens the URL in your configured browser.
- `/watch-toggle` — flip the kill switch.

## Files

```
.claude-plugin/plugin.json   plugin manifest
hooks/hooks.json             registers UserPromptSubmit / Stop / Notification hooks
scripts/on-prompt.sh         saves frontmost app, plays YouTube
scripts/on-stop.sh           pauses YouTube, restores frontmost app
scripts/play.applescript     finds YouTube tab and calls video.play()
scripts/pause.applescript    finds YouTube tab and calls video.pause()
commands/watch.md            /watch slash command
commands/watch-toggle.md     /watch-toggle slash command
install.sh                   symlinks into ~/.claude/plugins/
```

## Troubleshooting

- **Nothing happens** — the most common cause is forgetting the "Allow JavaScript from Apple Events" setting. Verify by running the script manually: `osascript scripts/pause.applescript "Google Chrome"`. If you see an error about JavaScript not being allowed, that's it.
- **The wrong app gets focused after pause** — make sure your terminal app (Ghostty, iTerm2, Terminal, Warp, …) is what's frontmost *at the moment you press Enter*. The plugin captures that and restores it. If you alt-tab to the browser before submitting, the browser is what it'll remember.
- **Multiple YouTube tabs open** — the plugin controls the first one it finds. Close the ones you don't want auto-controlled.
- **It plays during a long response with no interaction**, but I expected silence — every `UserPromptSubmit` resumes the video; every `Stop` pauses it. That's by design (you're working ↔ Claude is working).

## License

MIT
