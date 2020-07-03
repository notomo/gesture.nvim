local view = require "gesture/view"
local mapper = require "gesture/mapper"
local execute = require "gesture/executor".execute
local states = require "gesture/state"

local M = {}

local cmds = {
  draw = function(_)
    local state = view.open()

    states.update(state)
    states.save(state.id, state.window_bufnr, state)

    local inputs = state.inputs
    local no_wait_gesture = mapper.no_wait_match(state.bufnr, state.inputs)
    if no_wait_gesture ~= nil then
      view.close(state)
      return execute(no_wait_gesture.action)
    end

    local gesture = mapper.match(state.bufnr, state.inputs)
    local has_forward_match = mapper.has_forward_match(state.bufnr, inputs)
    view.render(state.window_bufnr, inputs, gesture, has_forward_match)
  end,
  finish = function(_)
    local state = states.get()
    if state == nil then
      return
    end

    local gesture = mapper.match(state.bufnr, state.inputs)

    view.close(state)

    if gesture ~= nil then
      return execute(gesture.action)
    end
  end,
  cancel = function(_)
    local state = states.get()
    view.close(state)
  end
}

M.parse_args = function(raw_args)
  args = {
    cmd = "draw"
  }

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

  return cmd(args)
end

vim.api.nvim_command("doautocmd User GestureSourceLoad")

return M