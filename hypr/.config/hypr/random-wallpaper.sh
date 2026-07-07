#!/usr/bin/env zsh
#
# Random wallpaper for the focused monitor.

WALLPAPER_DIR="$HOME/.dotfiles/wallpapers"
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/hypr/last-wallpaper"

# Name of the focused monitor (this is a Hyprland query, unaffected by hyprpaper).
FOCUSED_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

# What we set last time (empty on first run).
LAST_WALL=""
[[ -f "$STATE_FILE" ]] && LAST_WALL=$(<"$STATE_FILE")

# Pick a random image that isn't the last one. find yields absolute paths.
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
    ! -path "$LAST_WALL" | shuf -n 1)

# Nothing to switch to (e.g. only one image in the dir) -> exit quietly.
[[ -z "$WALLPAPER" ]] && exit 0

# Apply it to the focused monitor. fit_mode is optional (defaults to cover).
hyprctl hyprpaper wallpaper "$FOCUSED_MONITOR,$WALLPAPER"

# Remember it for next time.
mkdir -p "$(dirname "$STATE_FILE")"
printf '%s\n' "$WALLPAPER" > "$STATE_FILE"
