-- Daily shortcuts. Defaults the app ships with are left alone.

local lib = require("lib")

-- Window
rex.bind("cmd+s", "client.sidebar.toggle")

-- Pane navigation. While an editor has focus its own smart-splits mapping
-- takes the key, and hands it back with "rex focus" at the edge of its layout.
lib.bind_focus("ctrl+h", "left")
lib.bind_focus("ctrl+j", "down")
lib.bind_focus("ctrl+k", "up")
lib.bind_focus("ctrl+l", "right")

-- Actions
rex.bind("alt+cmd+o", "dev_pick")
