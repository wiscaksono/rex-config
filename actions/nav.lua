-- Focus the nearest pane in a direction and report whether focus moved, so a
-- client can fall back to its own behaviour when there is no pane that way.
local function focused_block()
  local view = rex.session.view {}
  if view == nil then
    return nil
  end
  for _, w in ipairs(view.windows or {}) do
    if w.window_id == view.active_window_id then
      return w.focused_block_id
    end
  end
  return nil
end

rex.action {
  name = "nav_focus",
  title = "Pane: Focus in Direction",
  category = "Panes",
  args = { direction = "string" },
  run = function(_, args)
    local before = focused_block()
    -- wrap keeps a single pane still, so "moved" stays false and the client
    -- can fall back to wrapping inside its own layout.
    local r, err = rex.session.focus_direction { direction = args.direction, wrap = true }
    if r == nil then
      error(err or "focus_direction failed", 0)
    end
    return { moved = before ~= focused_block() }
  end,
}
