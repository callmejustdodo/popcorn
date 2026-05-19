<p align="left">
  <img src="assets/popcorn-hero.png" alt="Pop-art-style popcorn kernel illustration" width="150">
</p>

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

## Setup

### 1. Install the plugin

Three slash commands inside Claude Code:

```text
/plugin marketplace add callmejustdodo/popcorn
/plugin install popcorn@popcorn
/reload-plugins
```

Claude Code clones the repo into `~/.claude/plugins/marketplaces/popcorn/` for you — no manual `git clone` needed.

### 2. Enable JavaScript from Apple Events in your browser

> [!IMPORTANT]
> Without this setting, the plugin silently does nothing. AppleScript can't drive a browser tab until you grant it permission once per browser.

- **Google Chrome / Arc / Brave / Edge** — bring the browser to the front, then in the macOS menu bar at the top of the screen: `View → Developer → Allow JavaScript from Apple Events`. Click **Allow** on the confirmation prompt, then restart the browser.
- **Safari** — `Safari → Settings → Advanced → Show Develop menu`, then `Develop → Allow JavaScript from Apple Events`.

The first time the script actually pokes a tab, the browser pops one more "Allow this app to control [browser]?" prompt. Click **Allow** there too.

### 3. (Optional) Pick a different browser

Default is Google Chrome. Switch via slash command:

```text
/popcorn:browser arc       # or: chrome, safari, brave, edge
/popcorn:browser           # no argument → prints the current setting
```

The choice is written to `~/.claude/.popcorn-browser` and read by the hooks on every prompt — no restart required. Make sure JS-from-Apple-Events is enabled in your chosen browser too (see step 2).

Advanced: setting `POPCORN_BROWSER` as a shell env var still works and takes precedence over the config file.

## Usage

1. Open any YouTube video or Short in your browser. (Or `/popcorn:watch <url>` once the plugin is loaded.)
2. Submit a prompt to Claude — the video auto-plays and your browser jumps to the front.
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
