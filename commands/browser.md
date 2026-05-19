---
description: Set or check the browser popcorn should control (Chrome / Arc / Safari / Brave / Edge)
argument-hint: <chrome|arc|safari|brave|edge>
allowed-tools: Bash
---

Set the browser popcorn controls. Argument: `$ARGUMENTS`

Run this bash command to update (or show) the config, then report the result in one short sentence:

```bash
case "$ARGUMENTS" in
  chrome|Chrome|"Google Chrome")  BROWSER="Google Chrome" ;;
  arc|Arc)                        BROWSER="Arc" ;;
  safari|Safari)                  BROWSER="Safari" ;;
  brave|Brave|"Brave Browser")    BROWSER="Brave Browser" ;;
  edge|Edge|"Microsoft Edge")     BROWSER="Microsoft Edge" ;;
  "")
    if [ -f "$HOME/.claude/.popcorn-browser" ]; then
      echo "current: $(cat "$HOME/.claude/.popcorn-browser")"
    else
      echo "current: Google Chrome (default — no config set)"
    fi
    exit 0
    ;;
  *) BROWSER="$ARGUMENTS" ;;
esac
mkdir -p "$HOME/.claude"
echo "$BROWSER" > "$HOME/.claude/.popcorn-browser"
echo "popcorn browser set to: $BROWSER"
```

The config file lives at `~/.claude/.popcorn-browser`. The hooks read it on every prompt; no restart needed.
