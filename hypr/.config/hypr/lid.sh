#!/usr/bin/env bash
# Lid / resume handling for eDP-1.
# close  -> disable eDP-1 ONLY if an external monitor is active (clamshell mode)
# open   -> re-enable eDP-1
# resume -> called by hypridle after_sleep_cmd; re-enable eDP-1 unless lid is
#           confirmed closed, then force dpms on.
set -euo pipefail

ENABLE_EDP='hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x1440", scale = 1, disabled = false })'
DISABLE_EDP='hl.monitor({ output = "eDP-1", disabled = true })'

case "${1:-}" in
  close)
    external=$(hyprctl monitors -j | jq '[.[] | select(.name != "eDP-1")] | length')
    if [ "$external" -gt 0 ]; then
      hyprctl eval "$DISABLE_EDP"
    fi
    # Undocked: do nothing. logind suspends the machine anyway, and leaving
    # eDP-1 enabled means resume has a monitor to come back to.
    ;;
  open)
    hyprctl eval "$ENABLE_EDP"
    ;;
  resume)
    # Re-enable unless the lid is confirmed closed (defaults to enabling if
    # /proc/acpi/button/lid is missing on this hardware).
    if ! grep -q closed /proc/acpi/button/lid/*/state 2>/dev/null; then
      hyprctl eval "$ENABLE_EDP"
    fi
    hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })'
    ;;
  *)
    echo "usage: lid.sh {close|open|resume}" >&2
    exit 1
    ;;
esac
