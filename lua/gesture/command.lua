local mapper = require("gesture/mapper")
local states = require("gesture/state")

local M = {}

local cmds = {
  draw = function(_)
    local state = states.get_or_create()
    local valid = state:update()
    if not valid then
      return
    end

    local inputs = state.inputs
    local bufnr = state.source_bufnr
    local nowait_gesture = mapper.nowait_match(bufnr, inputs)
    if nowait_gesture ~= nil then
      state.view:close()
      return nowait_gesture.execute()
    end

    local gesture = mapper.match(bufnr, inputs)
    local has_forward_match = mapper.has_forward_match(bufnr, inputs)
    state.view:render_input(inputs, gesture, has_forward_match)
  end,
  finish = function(_)
    local state = states.get()
    if state == nil then
      return
    end
    state.view:close()

    local gesture = mapper.match(state.source_bufnr, state.inputs)
    if gesture ~= nil then
      return gesture.execute()
    end
  end,
  cancel = function(_)
    local state = states.get()
    if state == nil then
      return
    end
    state.view:close()
  end,
}

M.parse_args = function(raw_args)
  args = {cmd = "draw"}

  if #raw_args == 0 then
    return args
  end

  for _, raw_arg in ipairs(raw_args) do
    if not vim.startswith(raw_arg, "--") then
      args.cmd = raw_arg
      break
    end
  end

  return args
end

M.main = function(...)
  local args = M.parse_args({...})

  local cmd = cmds[args.cmd]
  if cmd == nil then
    return vim.api.nvim_err_write("not found command: args=" .. vim.inspect(args) .. "\n")
  end

  local f = function()
    return cmd(args)
  end
  local ok, result = xpcall(f, debug.traceback)
  if not ok then
    error(result)
  end
  return result
end

vim.api.nvim_command("doautocmd User GestureSourceLoad")

return M
