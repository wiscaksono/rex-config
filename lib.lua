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

-- Programs that handle their own directional keys, so a key function bound to
-- one of these keys must return false and let the key reach the terminal.
local editors = { nvim = true, vim = true, vi = true }

local terminal = "com.superlogical.terminal"

-- The program in the foreground of a terminal block, or nil.
function M.foreground_name(block_id)
  if block_id == nil then
    return nil
  end
  local p = rex.block.call(terminal, "process", { block_id = block_id })
  return p and p.foreground and p.foreground.name or nil
end

-- Bind a key that moves focus in a direction, unless an editor has it.
function M.bind_focus(key, direction)
  rex.bind(key, function(ctx)
    if editors[M.foreground_name(ctx.block_id)] then
      return false
    end
    local r, err = rex.session.focus_direction { direction = direction, wrap = true }
    if r == nil then
      rex.log("warn", err or "focus_direction failed")
    end
    return true
  end)
end

-- Project folders under root: every folder one and two levels deep, plus
-- deeper ones that are their own repository. Items are ready for rex.ui.pick.
function M.project_dirs(root)
  local find_cmd = "find . -maxdepth 3 -type d "
    .. "-not -path '*/.git*' -not -path '*/node_modules*' -not -path '*/dist*' "
    .. "-not -path '*/build*' -not -path '*/target*' -not -path '*/vendor*' "
    .. "-not -path '*/.next*'"

  local script = table.concat({
    'cd "$1" || exit 1',
    find_cmd .. " |",
    "while IFS= read -r d; do",
    "  rel=${d#./}",
    '  [ -z "$rel" ] && continue',
    '  [ "$rel" = "." ] && continue',
    '  case "$rel" in',
    '    */*/*) [ -e "$rel/.git" ] && printf "%s\\n" "$rel" ;;',
    '    *) printf "%s\\n" "$rel" ;;',
    "  esac",
    "done",
  }, "\n")

  local r, err = rex.exec { "sh", "-c", script, "sh", root }
  if r == nil then
    error(err, 0)
  end
  if r.stdout == "" and not r.ok then
    error("list " .. root .. ": " .. r.stderr, 0)
  end

  local items = {}
  for rel in r.stdout:gmatch("[^\n]+") do
    rel = rel:gsub("/+$", "")
    items[#items + 1] = {
      id = root .. "/" .. rel,
      title = rel,
      subtitle = (root:gsub("^" .. os.getenv("HOME"), "~")),
      icon = "folder",
    }
  end
  table.sort(items, function(a, b)
    return a.title < b.title
  end)
  return items
end

return M
