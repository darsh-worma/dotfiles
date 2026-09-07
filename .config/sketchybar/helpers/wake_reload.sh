#!/bin/bash
# Debounced bar reload after wake.
#
# system_woke can fire several times per wake cycle (system wake, then display
# wake). Each `sketchybar --reload` re-executes the config, which spawns a fresh
# lua process, so overlapping reloads race: one process re-adds items another has
# already created, producing endless "item already exists" logging and leaving
# stacked lua processes behind. Cancel any pending reload before scheduling a new
# one so a burst of wake events collapses into a single reload.

PIDFILE="${TMPDIR:-/tmp}/sketchybar_wake_reload.pid"

if [ -f "$PIDFILE" ]; then
  kill "$(cat "$PIDFILE")" 2>/dev/null
fi

(
  sleep 3
  rm -f "$PIDFILE"
  /opt/homebrew/bin/sketchybar --reload
) >/dev/null 2>&1 &

echo $! >"$PIDFILE"
