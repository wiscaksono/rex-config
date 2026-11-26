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

-- Programs that handle ctrl+hjkl themselves. A key bound to those keys returns
-- false for these, so the key reaches the terminal. Add a program here when a
-- TUI moves around with ctrl+hjkl and Rex keeps stealing the keys.
local self_navigating = { nvim = true, vim = true, vi = true, ajsdb = true }

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
    if self_navigating[M.foreground_name(ctx.block_id)] then
      return false
    end
    M.nav_focus(direction, true)
    return true
  end)
end

local EPS = 1e-6

local function overlap(a, alen, b, blen)
  return math.min(a + alen, b + blen) - math.max(a, b)
end

-- Rectangles of the active window's blocks, and the focused block id.
local function active_rects()
  local view = rex.session.view {}
  if view == nil then
    return {}, nil
  end
  for _, w in ipairs(view.windows or {}) do
    if w.window_id == view.active_window_id then
      local out = {}
      local function walk(node)
        if type(node) ~= "table" then
          return
        end
        if node.block_id ~= nil and node.rect ~= nil then
          out[#out + 1] = { id = node.block_id, rect = node.rect }
        end
        local s = node.split
        if s ~= nil then
          walk(s.before)
          walk(s.after)
        end
      end
      for _, layer in ipairs(w.layers or {}) do
        walk(layer.layout)
      end
      return out, w.focused_block_id
    end
  end
  return {}, nil
end

-- Focus the nearest block in direction, wrapping within the same row or
-- column. Blocks that only touch on the perpendicular axis are never chosen,
-- so moving sideways in a stacked layout does nothing. Returns whether focus
-- moved.
function M.nav_focus(direction, wrap)
  local blocks, focused = active_rects()
  local current
  for _, b in ipairs(blocks) do
    if b.id == focused then
      current = b
    end
  end
  if current == nil then
    return false
  end

  local horizontal = direction == "left" or direction == "right"
  local forward = direction == "right" or direction == "down"

  -- Rect is [x, y, w, h].
  local along, across = 1, 2
  if not horizontal then
    along, across = 2, 1
  end
  local along_len, across_len = along + 2, across + 2

  local function shares_lane(r)
    local o = current.rect
    return overlap(o[across], o[across_len], r[across], r[across_len]) > EPS
  end

  local best, best_dist
  for _, b in ipairs(blocks) do
    if b.id ~= current.id and shares_lane(b.rect) then
      local o, r = current.rect, b.rect
      local dist
      if forward then
        dist = r[along] - (o[along] + o[along_len])
      else
        dist = o[along] - (r[along] + r[along_len])
      end
      if dist > -EPS then
        dist = math.max(dist, 0)
        if best_dist == nil or dist < best_dist then
          best, best_dist = b, dist
        end
      end
    end
  end

  if best == nil and wrap then
    local key
    for _, b in ipairs(blocks) do
      if b.id ~= current.id and shares_lane(b.rect) then
        local r = b.rect
        local k = forward and r[along] or -(r[along] + r[along_len])
        if key == nil or k < key then
          best, key = b, k
        end
      end
    end
  end

  if best == nil then
    return false
  end
  return rex.session.focus_block { block_id = best.id } ~= nil
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
