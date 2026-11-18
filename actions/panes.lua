-- Rename the focused pane.
rex.action {
  name = "rename_pane",
  title = "Rename Pane…",
  run = function(ctx, args)
    local name = rex.ui.input {
      title = "Pane label",
      placeholder = "tests, logs, api…",
      confirm = "Rename",
    }
    if name == nil or name == "" then
      return
    end

    local _, err = rex.session.set_block_label {
      block_id = ctx.block_id,
      label = name,
    }
    if err ~= nil then
      error(err, 0)
    end
  end,
}
