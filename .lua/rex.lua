--- Type definitions for the Rex Lua API, read only by lua-language-server.
--- Nothing here is loaded by Rex at runtime.
---@meta

---@class rex
rex = {}

---@class rex.ctx
---@field session_id? string
---@field block_id? string
---@field client_id? string
---@field origin? "key"|"palette"|"cli"|"api"|"script"|"timer"
---@field server? string

---@class rex.key_event
---@field keybinding? string
---@field prefix? string[]

-- Key bindings ---------------------------------------------------------------

---@param key string
---@param action string
---@param args? table
---@overload fun(key: string, fn: fun(ctx: rex.ctx, ev: rex.key_event): boolean?): nil
function rex.bind(key, action, args) end

---@param key string
---@param target? string|function
---@return integer removed
---@overload fun(mode: { mode: string }): nil
---@overload fun(binding: rex.binding): integer
function rex.unbind(key, target) end

---@param name string
---@param options? { exclusive?: boolean }
function rex.mode(name, options) end

---@class rex.binding
---@field key string
---@field mode? string
---@field action? string
---@field fn? function
---@field args? table
---@field source string

---@param filter? { key?: string, mode?: string, action?: string }
---@return rex.binding[]
function rex.bindings(filter) end

---@return { name: string, exclusive: boolean, source: string }[]
function rex.modes() end

-- Actions --------------------------------------------------------------------

---@class rex.action_opts
---@field name string Lowercase letters, digits, and underscores.
---@field title string Text shown in the command palette.
---@field run fun(ctx: rex.ctx, args: table): any
---@field description? string
---@field category? string Defaults to "Actions".
---@field keywords? string
---@field args? table<string, string>|table Argument types or a JSON Schema.
---@field repeats? boolean Run again while the key is held.

---@param opts rex.action_opts
function rex.action(opts) end

---@param name string
---@param args? table
---@return any result, string? err
function rex.invoke(name, args) end

---@class rex.client
rex.client = {}

---@param name string
---@param args? table
function rex.client.queue(name, args) end

-- Calling Rex ----------------------------------------------------------------

---@class rex.session
rex.session = {}

---@param args? table
---@return table? result, string? err
function rex.session.view(args) end

---@param args? table
---@return table? result, string? err
function rex.session.list_blocks(args) end

---@param args? table
---@return table? result, string? err
function rex.session.list_clients(args) end

---@param args? { block_id?: string }
---@return table? result, string? err
function rex.session.describe_block(args) end

---@param args { layout: rex.layout_node }
---@return { window_id: string, block_ids: string[] }? result, string? err
function rex.session.new_window(args) end

---@param args { layout: rex.layout_node, direction?: "horizontal"|"vertical", side?: "before"|"after", focus?: boolean, ratio?: number, block_id?: string }
---@return { block_ids: string[], split_ids: string[], anchor_block_id: string }? result, string? err
function rex.session.new_split(args) end

---@param args { layout: rex.layout_node }
---@return table? result, string? err
function rex.session.new_block(args) end

---@param args table
---@return table? result, string? err
function rex.session.new_layer(args) end

---@param args { window_id: string }
---@return table? result, string? err
function rex.session.close_window(args) end

---@param args { layer_id: string }
---@return table? result, string? err
function rex.session.close_layer(args) end

---@param args table
---@return table? result, string? err
function rex.session.move_block(args) end

---@param args { block_id: string, other_block_id: string }
---@return table? result, string? err
function rex.session.swap_blocks(args) end

---@param args { block_id: string }
---@return table? result, string? err
function rex.session.detach_block(args) end

---@param args { block_id: string }
---@return table? result, string? err
function rex.session.float_block(args) end

---@param args { block_id: string, zoom?: boolean }
---@return table? result, string? err
function rex.session.zoom_block(args) end

---@param args { block_id: string, direction: "left"|"right"|"up"|"down", amount?: number }
---@return table? result, string? err
function rex.session.resize_pane(args) end

---@param args table
---@return table? result, string? err
function rex.session.resize_layer(args) end

---@param args { layer_id: string }
---@return table? result, string? err
function rex.session.raise_layer(args) end

---@param args { layer_id: string }
---@return table? result, string? err
function rex.session.lower_layer(args) end

---@param args table
---@return table? result, string? err
function rex.session.move_window(args) end

---@param args { block_id: string }
---@return table? result, string? err
function rex.session.focus_block(args) end

---@param args { window_id: string }
---@return table? result, string? err
function rex.session.focus_window(args) end

---@param args { direction: "left"|"right"|"up"|"down" }
---@return table? result, string? err
function rex.session.focus_direction(args) end

---@param args? table
---@return table? result, string? err
function rex.session.focus_next_pane(args) end

---@param args? table
---@return table? result, string? err
function rex.session.focus_previous_pane(args) end

---@param args? table
---@return table? result, string? err
function rex.session.focus_next_window(args) end

---@param args? table
---@return table? result, string? err
function rex.session.focus_previous_window(args) end

---@param args { label: string }
---@return { revision: integer }? result, string? err
function rex.session.set_label(args) end

---@param args { window_id: string, label: string }
---@return { revision: integer }? result, string? err
function rex.session.set_window_label(args) end

---@param args { block_id: string, label: string }
---@return { revision: integer }? result, string? err
function rex.session.set_block_label(args) end

---@param args? table
---@return table? result, string? err
function rex.session.attach(args) end

---@param args? table
---@return table? result, string? err
function rex.session.detach(args) end

---@param args? table
---@return table? result, string? err
function rex.session.help(args) end

---@param method string
---@param args? table
---@return any result, string? err
function rex.call(method, args) end

---@class rex.block
rex.block = {}

---@param creator string For example "com.superlogical.terminal".
---@param method string
---@param args? table
---@return any result, string? err
function rex.block.call(creator, method, args) end

---@class rex.layout_node
---@field type? string

---@class rex.layout
rex.layout = {}

---@param opts { flavor: string, options?: rex.terminal_options }
---@return rex.layout_node
function rex.layout.block(opts) end

---@param ratio number Share given to the first layout, from 0 to 1.
---@param a rex.layout_node
---@param b rex.layout_node
---@return rex.layout_node
function rex.layout.horizontal(ratio, a, b) end

---@param ratio number Share given to the first layout, from 0 to 1.
---@param a rex.layout_node
---@param b rex.layout_node
---@return rex.layout_node
function rex.layout.vertical(ratio, a, b) end

---@class rex.terminal_options
---@field command? string[]
---@field shell? string "none" starts command directly.
---@field cwd? string
---@field initial_input? string
---@field exit? { on_completion?: boolean }

-- Events ---------------------------------------------------------------------

---@param event string
---@param fn fun(ctx: rex.ctx, ev: table)
function rex.on(event, fn) end

---@param event string
---@param filter? table|fun(ev: table, ctx: rex.ctx): boolean
---@param timeout? number
---@return table? ev, rex.ctx|"timeout"|nil ctx
function rex.wait(event, filter, timeout) end

---@param seconds number
function rex.sleep(seconds) end

---@param code? integer
function rex.stop(code) end

-- Hosts ----------------------------------------------------------------------

---@param host { label: string, endpoints?: string[], endpoint?: string, id?: string, icon?: string }
function rex.host(host) end

---@return string[]
function rex.servers() end

---@param label string
---@return { session: rex.session, block: rex.block, call: fun(method: string, args?: table): any }
function rex.server(label) end

-- Running commands -----------------------------------------------------------

---@class rex.exec_opts
---@field cwd? string
---@field env? table<string, string|false>
---@field clear_env? boolean
---@field stdin? string
---@field timeout? number
---@field stdout? false|fun(data: string)
---@field stderr? false|fun(data: string)
---@field text? boolean
---@field detach? boolean

---@class rex.exec_result
---@field code integer
---@field signal? string
---@field stdout string
---@field stderr string
---@field timed_out boolean
---@field ok boolean

---@class rex.exec_handle
---@field pid integer
local exec_handle = {}

---@param seconds? number
---@return rex.exec_result? result, "timeout"|string? err
function exec_handle:wait(seconds) end

---@param data string
---@return boolean? ok, string? err
function exec_handle:write(data) end

function exec_handle:close_stdin() end

---@param signal? string|integer
function exec_handle:kill(signal) end

---@return boolean
function exec_handle:running() end

---@class rex.exec
---@field start fun(argv: string[], opts?: rex.exec_opts): rex.exec_handle?, string?
---@operator call(table): rex.exec_result?, string?
rex.exec = {}

---@param argv string[]
---@param opts? rex.exec_opts
---@return rex.exec_handle? handle, string? err
function rex.exec.start(argv, opts) end

-- Timers ---------------------------------------------------------------------

---@class rex.timer
local timer = {}

function timer:cancel() end

---@return boolean
function timer:active() end

---@param seconds number
---@param fn fun(ctx: rex.ctx)
---@return rex.timer
function rex.after(seconds, fn) end

---@param seconds number
---@param fn fun(ctx: rex.ctx)
---@return rex.timer
function rex.every(seconds, fn) end

-- JSON and logging -----------------------------------------------------------

---@class rex.json
rex.json = {}

---@param value any
---@param opts? { indent?: boolean }
---@return string? text, string? err
function rex.json.encode(value, opts) end

---@param text string
---@return any value, string? err
function rex.json.decode(text) end

---@param level? "debug"|"info"|"warn"|"error"
---@param message string
---@overload fun(message: string): nil
function rex.log(level, message) end

-- Prompts --------------------------------------------------------------------

---@class rex.ui
rex.ui = {}

---@class rex.ui.input_opts
---@field title string
---@field placeholder? string
---@field value? string
---@field confirm? string
---@field timeout? number

---@class rex.ui.pick_opts
---@field title string
---@field placeholder? string
---@field value? string
---@field confirm? string
---@field timeout? number
---@field multiple? boolean
---@field allow_other? boolean
---@field items? (string|{ id: string, title?: string, subtitle?: string, icon?: string, detail?: string, selected?: boolean })[]

---@param opts rex.ui.input_opts
---@return string? value, "cancelled"|"timeout"|"no_client"|"unsupported"|"busy"|"failed"? reason, string? detail
function rex.ui.input(opts) end

---@param opts rex.ui.pick_opts
---@return string|string[]|{ text: string }|nil value, string? reason, string? detail
function rex.ui.pick(opts) end

-- Script values --------------------------------------------------------------

---@type table<string, any>
rex.args = {}

---@type string
rex.session_id = nil

---@type string
rex.block_id = nil
