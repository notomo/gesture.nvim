local M = {}

local State = require("gesture.core.state")

local draw_options = {
  show_board = true,
  length_thresholds = {
    x = 5,
    y = 5,
  },
  winblend = 100,
}
function M.draw(raw_opts)
  local opts = vim.tbl_deep_extend("force", draw_options, raw_opts or {})

  local state = State.get_or_create(function()
    return require("gesture.view").open(opts.winblend)
  end)
  local valid = state:update(opts.length_thresholds)
  if not valid then
    return
  end

  local ctx = state:action_context()

  local can_match = state.matcher:can_match(ctx)
  if type(can_match) == "string" then
    state:close()

    local err = can_match
    return require("gesture.vendor.misclib.message").error(err)
  end

  local nowait_gesture = state.matcher:nowait_match(ctx, can_match)
  if type(nowait_gesture) == "string" then
    state:close()

    local err = nowait_gesture
    return require("gesture.vendor.misclib.message").error(err)
  end

  if nowait_gesture then
    state:close()

    local err = nowait_gesture:execute(ctx)
    if err then
      require("gesture.vendor.misclib.message").error(err)
    end
    return
  end

  local gesture = state.matcher:match(ctx, can_match)
  if type(gesture) == "string" then
    state:close()
    local err = gesture
    return require("gesture.vendor.misclib.message").error(err)
  end

  state.view:render_input(ctx.inputs, gesture, can_match, opts.show_board)
end

function M.suspend()
  local state = State.get()
  if not state then
    return
  end
  state:suspend()
end

function M.finish()
  local state = State.get()
  if not state then
    return
  end

  local ctx = state:action_context()
  state:close()

  local gesture = state.matcher:match(ctx, true)
  if type(gesture) == "string" then
    local err = gesture
    return require("gesture.vendor.misclib.message").error(err)
  end

  if gesture then
    local err = gesture:execute(ctx)
    if err then
      return require("gesture.vendor.misclib.message").error(err)
    end
    return
  end
end

--- @param window_id integer?
function M.cancel(window_id)
  local state = State.get(window_id)
  if not state then
    return
  end
  state:close()
end

return M
