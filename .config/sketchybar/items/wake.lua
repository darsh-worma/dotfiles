-- After display sleep/wake the bar sometimes keeps its item backgrounds but
-- stops drawing any icons/labels. A full reload rebuilds the bar window and
-- clears it up, so do that automatically a moment after waking.
local wake = sbar.add("item", "wake_watcher", {
  drawing = false,
  updates = true,
})

-- system_woke fires more than once per wake, so the reload is debounced in the
-- helper; scheduling it inline here would race N reloads against each other.
wake:subscribe("system_woke", function()
  os.execute(os.getenv("HOME") .. "/.config/sketchybar/helpers/wake_reload.sh >/dev/null 2>&1 &")
end)
