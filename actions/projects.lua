local lib = require("lib")

-- Pick a project folder anywhere under ~/Developer and open a window there.
rex.action {
  name = "dev_pick",
  title = "Developer: Open Project…",
  category = "Projects",
  run = function(ctx)
    local root = os.getenv("HOME") .. "/Developer"
    local dir = rex.ui.pick {
      title = "Open project",
      placeholder = "Filter project",
      items = lib.project_dirs(root),
    }
    if dir == nil then
      return
    end
    return lib.open_dir(dir, ctx)
  end,
}

-- Pick one of the Polaris repos and open a window there.
rex.action {
  name = "polaris_repo",
  title = "Polaris: Open Repo…",
  category = "Projects",
  run = function(ctx)
    local root = os.getenv("HOME") .. "/Developer/SINARMAS/polaris"
    local dir = rex.ui.pick {
      title = "Polaris repo",
      placeholder = "Filter repos",
      items = lib.dirs_under(root, "~/Developer/SINARMAS/polaris"),
    }
    if dir == nil then
      return
    end
    return lib.open_dir(dir, ctx)
  end,
}
