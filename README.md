<p align="left">
  <img src="assets/popcorn-hero.png" alt="Pop-art-style popcorn kernel illustration" width="150">
</p>

# popcorn

Grab some popcorn while your CLI agent works.

A Claude Code plugin that auto-plays your open YouTube / TikTok / Instagram tab while the agent is working and pauses it the moment the agent needs your input — then refocuses your terminal. macOS only. Works with Chrome (default), Arc, Brave, Edge, and Safari.

## Setup

### 1. Install

Inside Claude Code:

```text
/plugin marketplace add callmejustdodo/popcorn
/plugin install popcorn@popcorn
/reload-plugins
```

### 2. Allow AppleScript to drive your browser

> [!IMPORTANT]
> Without this, the plugin silently does nothing. One-time setup per browser.

**Chrome / Arc / Brave / Edge** — bring the browser to the front, then in the macOS menu bar: `View → Developer → Allow JavaScript from Apple Events`. Click **Allow**, restart the browser.

**Safari** — `Safari → Settings → Advanced → Show Develop menu`, then `Develop → Allow JavaScript from Apple Events`.

The first time the plugin controls a tab, the browser asks one more permission. Click **Allow** there too.

### 3. (Optional) Use a non-Chrome browser

```text
/popcorn:browser arc       # or: chrome, safari, brave, edge
/popcorn:browser           # show current setting
```

## How to use

1. Open a YouTube video / Short, TikTok feed, or Instagram Reel in your browser (or run `/popcorn:watch <url>`).
2. Send a prompt — video plays, browser jumps to the front.
3. Claude finishes or asks for input — video pauses, your terminal comes back.

## Commands

| Command | What it does |
|---|---|
| `/popcorn:watch <url>` | Open a YouTube / TikTok / Instagram URL in your configured browser |
| `/popcorn:browser <name>` | Switch browser (`chrome`, `arc`, `safari`, `brave`, `edge`) |
| `/popcorn:watch-toggle` | Temporarily disable / re-enable the plugin |

## Troubleshooting

- **Nothing happens** → "Allow JavaScript from Apple Events" isn't enabled yet. Verify with `osascript scripts/pause.applescript "Google Chrome"` — if your video doesn't pause, the setting isn't applied.
- **Wrong app gets focused after pause** → the plugin remembers whatever was frontmost when you pressed Enter. Submit prompts from your terminal, not from the browser.
- **Wrong tab being controlled** → the plugin prefers the active tab of your frontmost browser window. If that one doesn't match (YouTube / TikTok / Instagram), it falls back to the first match in window-then-tab order. Make sure the tab you want is the active one in your frontmost window.

## Roadmap

- Codex CLI adapter (no native hooks — needs a pty / stdout watcher)
- Multi-tab round-robin
- Multi-agent dev support — coordinate play/pause across parallel agent sessions (cmux, Claude agents, etc.) so the video only pauses when *every* agent is idle
- In-terminal browser support — drive a terminal-native browser (carbonyl, w3m, etc.) so the video lives inside the terminal pane instead of a separate window

## License

MIT
