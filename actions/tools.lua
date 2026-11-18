local terminal = "com.superlogical.terminal"

-- The window that holds a block, so a floating layer lands in the tab the
-- person is looking at instead of whichever window is active.
local function window_of(block_id)
  if block_id == nil then
    return nil
  end
  local info = rex.session.describe_block { block_id = block_id }
  return info and info.block and info.block.window_id or nil
end

local function url_to_path(url)
  return (url:gsub("^file://[^/]*", ""))
end

-- Directory the block is in, for actions that cannot name one.
local function dir_of(block_id)
  if block_id == nil then
    return nil
  end
  local pwd = rex.block.call(terminal, "pwd", { block_id = block_id })
  if pwd == nil or pwd.pwd == nil then
    return nil
  end
  return url_to_path(pwd.pwd)
end

-- Run a command in a floating layer over the window that owns the block.
local function float_command(ctx, command, cwd)
  local layer, err = rex.session.new_layer {
    window_id = window_of(ctx.block_id),
    bounds = { x = 0.08, y = 0.08, w = 0.84, h = 0.84 },
    focus = true,
    layout = rex.layout.block {
      flavor = terminal .. ".shell",
      options = { command = command, cwd = cwd },
    },
  }
  if layer == nil then
    error(err or "new_layer failed", 0)
  end
  return { layer_id = layer.layer_id, block_id = layer.block_ids[1] }
end

rex.action {
  name = "lazygit_float",
  title = "Lazygit (Floating)…",
  category = "Tools",
  args = { dir = "string?" },
  run = function(ctx, args)
    local dir = args.dir or dir_of(ctx.block_id)
    return float_command(ctx, { "lazygit" }, dir)
  end,
}
