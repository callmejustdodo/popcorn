---
name: Bug report
about: Something popcorn does that it shouldn't, or doesn't do that it should
title: ''
labels: bug
assignees: ''
---

## What happened
<!-- One sentence. "Pause doesn't fire after Claude stops" beats "popcorn is broken." -->

## What you expected to happen
<!-- One sentence. -->

## Reproduction
<!-- Numbered steps from a known state. Include the platform (YouTube / TikTok / Instagram) and the page type (regular video, Short, Reel, etc.). -->

1.
2.
3.

## Environment

- macOS version: <!-- `sw_vers -productVersion` -->
- Browser + version: <!-- e.g. Chrome 130, Arc 1.62.0 -->
- Terminal: <!-- Ghostty / iTerm2 / Terminal.app / Warp / ... -->
- popcorn version: <!-- `grep version ~/.claude/plugins/cache/popcorn/popcorn/*/\.claude-plugin/plugin.json` -->
- Configured browser: <!-- `cat ~/.claude/.popcorn-browser 2>/dev/null || echo "default (Google Chrome)"` -->

## Sanity-check the obvious one first

- [ ] `View → Developer → Allow JavaScript from Apple Events` is enabled in the browser you're using.
- [ ] When you run `osascript ~/.claude/plugins/cache/popcorn/popcorn/*/scripts/pause.applescript "Google Chrome"` against a playing video, the video pauses. (If not, the AppleEvents permission isn't actually granted.)

## DOM probe output

Run this with the relevant video tab open and paste the result:

```bash
osascript <<'EOF'
using terms from application "Google Chrome"
tell application "Google Chrome"
  repeat with i from 1 to count of windows
    repeat with j from 1 to count of tabs of window i
      set u to URL of tab j of window i
      if (u contains "youtube.com") or (u contains "tiktok.com") or (u contains "instagram.com") then
        tell tab j of window i to set r to (execute javascript "JSON.stringify({url:location.href,videos:Array.from(document.querySelectorAll('video')).map(function(v){var r=v.getBoundingClientRect();return{paused:v.paused,t:Math.floor(v.currentTime),w:Math.floor(r.width),h:Math.floor(r.height)};})})")
        return r
      end if
    end repeat
  end repeat
end tell
end using terms from
EOF
```

```
<paste output here>
```

## Anything else
<!-- Logs, screenshots, theories. -->
