# Rex config

Lua configuration for Rex, read by the Rex server on this machine. `init.lua`
is the entry point; `require` loads the other files from this directory.

| File | Holds |
| --- | --- |
| `init.lua` | Loads `keys`, `modes`, and `actions`. Nothing else. |
| `keys.lua` | Shortcuts used every day. |
| `lib.lua` | Helpers shared by actions. Returns a table. |
| `modes/` | One file per key mode, loaded by `modes/init.lua`. |
| `actions/` | One file per action group, loaded by `actions/init.lua`. |
| `.luarc.json` | Tells lua-language-server that `rex` is a global. |
| `.stylua.toml` | Formatter settings. |
| `.lua/rex.lua` | `---@meta` stub of the Rex Lua API for autocomplete. Never loaded by Rex. |

## Editing rules

- Leave the shortcuts Rex ships with alone. They are set by the app, and a key
  set in the app wins over this file. List them with `rex -C <client> actions`.
- Add a binding only when it does something the defaults do not. Keep one
  binding per key.
- Custom actions: `name`, `title`, and `run` are required. The name is lowercase
  letters, digits, and underscores, with no dot.
- A binding inside a mode must name an action. Runnable Lua there needs a custom
  action.
- When a key is bound both alone and as the start of a sequence, the newer line
  wins and the older one never runs.
- Group by domain, not by action: one file in `actions/` and `modes/` per area
  such as projects or panes. Register a new file in that directory's `init.lua`.
- Helpers used by more than one action go in `lib.lua`. Split a file when it
  passes about 120 lines.

## Key syntax

```lua
rex.bind("cmd+d", "pane.split", { direction = "right" })
rex.bind("ctrl+b>c", "client.tab.new")                          -- sequence
rex.bind("resize/left", "pane.resize", { direction = "left" })  -- inside a mode
```

Modifiers are `cmd`, `ctrl`, `alt`, and `shift`. Write a key without shift
applied, so `+` on a US layout is `cmd+shift+=`.

## Lua API notes

- The file runs top to bottom at load. Calls that need a client, such as
  `rex.session.view` or `rex.session.new_window`, fail there. Put them inside an
  action's `run`, a key function, or a timer.
- `rex.on` only runs in scripts started with `rex do`, never in this file.
- `os.execute` and `io.popen` raise an error. Use `rex.exec` instead.
- A failed call returns `nil` and an error message. Check the second value when
  the result matters.
- Full API: https://www.superlogical.com/rex/docs/reference/lua.md

## Reload and verify

```sh
rex config check     # parses the file, reports errors with file:line
rex config reload    # applies it; refused over a remote connection
rex keymap           # merged shortcuts, with the source line of each
```

Run all three after a change. `rex keymap` is the real check: it shows what the
server loaded, including modes and blocked keys. A misspelled action name only
shows up in the client, as a warning when it loads the keymap.

To try one action without reloading, run its file from this directory. The
working directory matters, because `require` resolves against it:

```sh
rex do actions/panes.lua --action rename_pane
```

## Formatting

StyLua formats these files using `.stylua.toml`. The binary comes from Mason:

```sh
~/.local/share/nvim/mason/bin/stylua .            # rewrite files
~/.local/share/nvim/mason/bin/stylua --check .    # report only
```

Neovim formats on save with the same config, so a save and a CLI run agree.
`call_parentheses = "NoSingleTable"` keeps the `rex.action { ... }` form the Rex
docs use.

## Editor support

`.lua/rex.lua` covers the API as documented. When adding a call it does not
declare, add the stub too, then check the workspace:

```sh
~/.local/share/nvim/mason/bin/lua-language-server --check=.
```

The config lives on the machine that runs the Rex server. A remote host has its
own copy.
