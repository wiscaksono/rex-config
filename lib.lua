-- Helpers shared by actions.

local M = {}

local shell = "com.superlogical.terminal.shell"

-- Open a window with a shell in dir, focus it, and return the new IDs.
-- When ctx carries a client, that app is asked to show the new window too.
function M.open_dir(dir, ctx)
  local w, err = rex.session.new_window {
    layout = rex.layout.block {
      flavor = shell,
      options = { cwd = dir },
    },
  }
  if w == nil then
    error(err or "new_window failed", 0)
  end

  local block_id = w.block_ids and w.block_ids[1] or nil
  if block_id ~= nil then
    rex.session.focus_block { block_id = block_id }
  end

  if ctx ~= nil and ctx.client_id ~= nil then
    pcall(rex.client.queue, "session.select", {
      session_id = ctx.session_id or rex.session_id,
      window_id = w.window_id,
    })
  end

  return { window_id = w.window_id, block_id = block_id }
end

-- List the directories directly under root, as items for rex.ui.pick.
function M.dirs_under(root, subtitle)
  local r, err = rex.exec { "find", root, "-mindepth", "1", "-maxdepth", "1", "-type", "d" }
  if r == nil then
    error(err, 0)
  end
  if not r.ok then
    error("find " .. root .. ": " .. r.stderr, 0)
  end

  local items = {}
  for path in r.stdout:gmatch("[^\n]+") do
    local name = path:match("([^/]+)$")
    if name ~= nil and name:sub(1, 1) ~= "." then
      items[#items + 1] = {
        id = path,
        title = name,
        subtitle = subtitle,
        icon = "folder",
      }
    end
  end
  table.sort(items, function(a, b)
    return a.title < b.title
  end)
  return items
end

return M
