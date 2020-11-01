local mapper = require("gesture/mapper")
local states = require("gesture/state")

local M = {}

local GesturePlugin = {}

function GesturePlugin.draw()
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
end

function GesturePlugin.finish()
  local state = states.get()
  if state == nil then
    return
  end
  state.view:close()

  local gesture = mapper.match(state.source_bufnr, state.inputs)
  if gesture ~= nil then
    return gesture.execute()
  end
end

function GesturePlugin.cancel()
  local state = states.get()
  if state == nil then
    return
  end
  state.view:close()
end

M.main = function(...)
  local cmd_name = ({...})[1] or "draw"
  local cmd = GesturePlugin[cmd_name]
  if cmd == nil then
    return vim.api.nvim_err_write("not found command: cmd=" .. cmd_name .. "\n")
  end

  local ok, result = xpcall(cmd, debug.traceback)
  if not ok then
    error(result)
  end
  return result
end

vim.api.nvim_command("doautocmd User GestureSourceLoad")

return M
