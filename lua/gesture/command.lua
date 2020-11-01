local states = require("gesture/state")

local M = {}

local Command = {}

function Command.draw()
  local state = states.get_or_create()
  local valid = state:update()
  if not valid then
    return
  end

  local inputs = state.inputs
  local nowait_gesture = state.mapper:nowait_match(inputs)
  if nowait_gesture ~= nil then
    state.view:close()
    return nowait_gesture.execute()
  end

  local gesture = state.mapper:match(inputs)
  local has_forward_match = state.mapper:has_forward_match(inputs)
  state.view:render_input(inputs, gesture, has_forward_match)
end

function Command.finish()
  local state = states.get()
  if state == nil then
    return
  end
  state.view:close()

  local gesture = state.mapper:match(state.inputs)
  if gesture ~= nil then
    return gesture.execute()
  end
end

function Command.cancel()
  local state = states.get()
  if state == nil then
    return
  end
  state.view:close()
end

M.main = function(...)
  local cmd_name = ({...})[1] or "draw"
  local cmd = Command[cmd_name]
  if cmd == nil then
    return vim.api.nvim_err_write("[gesture] not found command: " .. cmd_name .. "\n")
  end

  local ok, result = xpcall(cmd, debug.traceback)
  if not ok then
    error(result)
  end
  return result
end

vim.api.nvim_command("doautocmd User GestureSourceLoad")

return M
