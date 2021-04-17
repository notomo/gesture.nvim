local messagelib = require("gesture.lib.message")
local State = require("gesture.state").State

local M = {}
local Command = {}
M.Command = Command

function Command.new(name, ...)
  local args = {...}
  local f = function()
    return Command[name](unpack(args))
  end

  local ok, result, err = xpcall(f, debug.traceback)
  if not ok then
    return messagelib.error(result)
  elseif err then
    return messagelib.user_error(err)
  end
  return result
end

function Command.draw()
  local state = State.get_or_create()
  local valid = state:update()
  if not valid then
    return
  end

  local inputs = state.inputs
  local nowait_gesture = state.matcher:nowait_match(inputs)
  if nowait_gesture ~= nil then
    state:close()
    return nowait_gesture:execute()
  end

  local gesture = state.matcher:match(inputs)
  local has_forward_match = state.matcher:has_forward_match(inputs)
  state.view:render_input(inputs, gesture, has_forward_match)
end

function Command.finish()
  local state = State.get()
  if state == nil then
    return
  end
  state:close()

  local gesture = state.matcher:match(state.inputs)
  if gesture ~= nil then
    return gesture:execute()
  end
end

function Command.cancel(window_id)
  vim.validate({window_id = {window_id, "number", true}})
  local state = State.get(window_id)
  if state == nil then
    return
  end
  state:close()
end

vim.cmd("doautocmd User GestureSourceLoad")

return M
