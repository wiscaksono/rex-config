local lib = require("lib")

-- Pick a project and open a window there.
rex.action {
  name = "open_project",
  title = "Open Project…",
  category = "Projects",
  run = function(ctx, args)
    local home = os.getenv("HOME")
    local dir = rex.ui.pick {
      title = "Open project",
      placeholder = "Filter",
      items = {
        {
          id = home .. "/Developer/SINARMAS/polaris",
          title = "polaris",
          subtitle = "SINARMAS",
          icon = "folder",
        },
        {
          id = home .. "/Developer/SANDBOX",
          title = "SANDBOX",
          subtitle = "~/Developer",
          icon = "folder",
        },
      },
    }
    if dir == nil then
      return
    end
    return lib.open_dir(dir)
  end,
}

-- Pick one of the Polaris repos and open a window there.
rex.action {
  name = "polaris_repo",
  title = "Polaris: Open Repo…",
  category = "Projects",
  run = function(ctx, args)
    local root = os.getenv("HOME") .. "/Developer/SINARMAS/polaris"
    local dir = rex.ui.pick {
      title = "Polaris repo",
      placeholder = "Filter repos",
      items = lib.dirs_under(root, "~/Developer/SINARMAS/polaris"),
    }
    if dir == nil then
      return
    end
    return lib.open_dir(dir)
  end,
}
