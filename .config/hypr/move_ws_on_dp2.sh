#!/usr/bin/env bash
# Moves all workspaces living on eDP-1 to DP-2 when DP-2 is present.
# Requires: jq

SRC="eDP-1"
DST="DP-2"

move_ws() {
  # Only act if the destination monitor exists (i.e., plugged in)
  if ! hyprctl -j monitors | jq -e ".[] | select(.name==\"$DST\")" >/dev/null; then
    return
  fi

  # Get all workspace IDs currently on SRC and move them
  hyprctl -j workspaces \
    | jq -r ".[] | select(.monitor==\"$SRC\") | .id" \
    | while read -r ws; do
        [ -n "$ws" ] && hyprctl dispatch moveworkspacetomonitor "$ws" "$DST"
      done
}

# Run once at startup (handles the case where DP-2 is already plugged in)
move_ws

# Then react to hot-plug events
# (event name is lowercase: monitoradded)
hyprctl -s monitoradded | while read -r _; do
  move_ws
done
