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

  local can_match, can_match_err = state.matcher:can_match(ctx)
  if can_match_err then
    state:close()
    require("gesture.vendor.misclib.message").error(can_match_err)
  end

  local nowait_gesture, nowait_err = state.matcher:nowait_match(ctx, can_match)
  if nowait_err then
    state:close()
    require("gesture.vendor.misclib.message").error(nowait_err)
  end

  if nowait_gesture then
    state:close()
    local err = nowait_gesture:execute(ctx)
    if err then
      require("gesture.vendor.misclib.message").error(err)
    end
    return
  end

  local gesture, match_err = state.matcher:match(ctx, can_match)
  if match_err then
    state:close()
    require("gesture.vendor.misclib.message").error(match_err)
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

  local gesture, match_err = state.matcher:match(ctx, true)
  if match_err then
    require("gesture.vendor.misclib.message").error(match_err)
  end

  if gesture then
    local err = gesture:execute(ctx)
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

return M
