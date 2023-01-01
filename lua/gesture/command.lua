local M = {}

local State = require("gesture.state")

function M.draw()
  local state = State.get_or_create()
  local valid = state:update()
  if not valid then
    return
  end

  local inputs = state.inputs
  local nowait_gesture = state.matcher:nowait_match(inputs)
  if nowait_gesture then
    local param = state:close()
    local err = nowait_gesture:execute(param)
    if err then
      require("gesture.vendor.misclib.message").error(err)
    end
    return
  end

  local gesture = state.matcher:match(inputs)
  local has_forward_match = state.matcher:has_forward_match(inputs)
  state.view:render_input(inputs, gesture, has_forward_match)
end

function M.finish()
  local state = State.get()
  if not state then
    return
  end

  local param = state:close()
  local gesture = state.matcher:match(state.inputs)
  if gesture then
    local err = gesture:execute(param)
    if err then
      require("gesture.vendor.misclib.message").error(err)
    end
    return
  end
end

function M.cancel(window_id)
  vim.validate({ window_id = { window_id, "number", true } })
  local state = State.get(window_id)
  if not state then
    return
  end
  state:close()
end

function M.register(info)
  require("gesture.model.setting").register(info)
end

function M.clear()
  require("gesture.model.setting").clear()
end

return M
