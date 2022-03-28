local ShowError = require("gesture.vendor.misclib.error_handler").for_show_error()
local ShowAsUserError = require("gesture.vendor.misclib.error_handler").for_show_as_user_error()

local State = require("gesture.state").State

function ShowAsUserError.draw()
  local state = State.get_or_create()
  local valid = state:update()
  if not valid then
    return
  end

  local inputs = state.inputs
  local nowait_gesture = state.matcher:nowait_match(inputs)
  if nowait_gesture then
    local param = state:close()
    return nowait_gesture:execute(param)
  end

  local gesture = state.matcher:match(inputs)
  local has_forward_match = state.matcher:has_forward_match(inputs)
  state.view:render_input(inputs, gesture, has_forward_match)
end

function ShowAsUserError.finish()
  local state = State.get()
  if not state then
    return
  end

  local param = state:close()
  local gesture = state.matcher:match(state.inputs)
  if gesture then
    return gesture:execute(param)
  end
end

function ShowError.cancel(window_id)
  vim.validate({ window_id = { window_id, "number", true } })
  local state = State.get(window_id)
  if not state then
    return
  end
  state:close()
end

function ShowError.register(info)
  require("gesture.model.setting").register(info)
end

function ShowError.clear()
  require("gesture.model.setting").clear()
end

return vim.tbl_extend("force", ShowAsUserError:methods(), ShowError:methods())
