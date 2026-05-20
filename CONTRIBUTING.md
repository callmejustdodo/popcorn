# Contributing to popcorn

Thanks for taking interest. popcorn is small and macOS-only — most contributions are platform-specific tweaks (new browsers, new video sites) or focus/UX polish. PRs welcome; this file describes the actual workflow so you don't have to reverse-engineer it.

## Repo layout

```
.claude-plugin/
  plugin.json          plugin manifest (version lives here)
  marketplace.json     self-hosting marketplace manifest (version lives here too)
hooks/hooks.json       registers UserPromptSubmit / Stop / Notification hooks
scripts/
  on-prompt.sh         saves frontmost app, calls play.applescript
  on-stop.sh           calls pause.applescript, restores frontmost app
  play.applescript     finds the visible <video> tab and resumes
  pause.applescript    finds the visible <video> tab and pauses
commands/
  watch.md             /popcorn:watch <url>
  watch-toggle.md      /popcorn:watch-toggle
  browser.md           /popcorn:browser <name>
```

## Local development

### Test against your own Claude Code install

Claude Code copies installed plugins into `~/.claude/plugins/cache/popcorn/popcorn/<version>/`. Files in that path are what actually run — your repo checkout is *not* live. Two ways to iterate:

**Fast loop (no version bump):** edit a file in your repo, then `cp` it into the cache:

```bash
cp scripts/play.applescript ~/.claude/plugins/cache/popcorn/popcorn/<version>/scripts/
```

The hook scripts read AppleScript files at runtime, so the change takes effect on the next prompt — no `/reload-plugins` needed for `.applescript` edits. For `hooks.json`, `commands/*.md`, or anything Claude Code reads at load time, run `/reload-plugins` after the copy.

**Clean loop (version bump):** bump version in `.claude-plugin/plugin.json` AND `.claude-plugin/marketplace.json` (both), then:

```
/plugin uninstall popcorn@popcorn
/plugin install popcorn@popcorn
/reload-plugins
```

### Add a new video platform

1. **Probe the DOM live** before changing code. Open the platform's video page in Chrome, then:

   ```bash
   osascript <<'EOF'
   using terms from application "Google Chrome"
   tell application "Google Chrome"
     repeat with i from 1 to count of windows
       repeat with j from 1 to count of tabs of window i
         set u to URL of tab j of window i
         if u contains "PLATFORM.com" then
           tell tab j of window i to set r to (execute javascript "JSON.stringify(Array.from(document.querySelectorAll('video')).map(function(v){var r=v.getBoundingClientRect();return{paused:v.paused,t:Math.floor(v.currentTime),w:Math.floor(r.width),h:Math.floor(r.height),inView:r.top<window.innerHeight&&r.bottom>0&&r.width>0};}))")
           return r
         end if
       end repeat
     end repeat
   end tell
   end using terms from
   EOF
   ```

   Confirm there's a `<video>` element with non-zero dimensions. If everything is 0×0 or the platform uses a custom player without `<video>`, the existing selector won't work and you'll need a different approach.

2. **Try `play()` and `pause()` directly** via the same `execute javascript` pattern. Note any autoplay gates, double-pause behavior, or platform-specific tab-visibility behavior. TikTok and Instagram already manage play/pause on `visibilitychange`; popcorn's calls are no-ops on top of that, which is fine.

3. **Add the URL to `isSupportedUrl`** in both `scripts/play.applescript` and `scripts/pause.applescript`. That's literally the change once probing confirms the existing selector works.

4. **Bump version** in `plugin.json` and `marketplace.json` (both `version` fields and the inner plugin entry's `version`).

5. **Update README** — platform list in the intro, the "How to use" line, the watch command row, troubleshooting if relevant.

6. **Reinstall locally and verify end-to-end** with the hooks (submit a real prompt, watch it pause/play). Include before/after probe output in the PR description.

## Commit and PR conventions

- Lower-case, imperative subject lines (`feat: ...`, `fix: ...`, `docs: ...`, `chore: ...`).
- Body explains *why*, not what — the diff covers the what.
- For non-trivial changes, include a `Confidence: high | medium | low` and a `Scope-risk: narrow | moderate | broad` trailer. If you didn't test a live edge case, add `Not-tested: <what>`.
- Keep PRs single-purpose. If you're tempted to bundle a refactor with a feature, split it.

## Things to not do

- Don't add features for hypothetical platforms or browsers without a real probe + verification pair.
- Don't broaden the URL filter beyond domain matches that you've tested live. A typo like matching `youtu.be` in a comment-mention page would hijack random tabs.
- Don't move `pause.applescript` to also change focus. The pause path needs to stay silent so `on-stop.sh` can decide focus restoration unambiguously.
- Don't introduce non-macOS code paths in the main scripts. If you want Linux/Windows support, design it as a sibling adapter — don't pollute the AppleScript files.

## Releasing

When `main` has shippable changes, bump the version in `plugin.json` and `marketplace.json`, write release notes in the commit body, push. Users update with `/plugin uninstall` + `/plugin install` (we don't have an in-place update yet — that's a roadmap item).

## Questions

Open a GitHub Discussion or issue. No formal CoC yet; default to being kind.
