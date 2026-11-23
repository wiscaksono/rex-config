-- Focus the pane in a direction and report whether focus moved, so a client
-- can fall back to its own behaviour when there is no pane that way.
local lib = require("lib")

rex.action {
  name = "nav_focus",
  title = "Pane: Focus in Direction",
  category = "Panes",
  args = { direction = "string", wrap = "boolean?" },
  run = function(_, args)
    return { moved = lib.nav_focus(args.direction, args.wrap ~= false) }
  end,
}
