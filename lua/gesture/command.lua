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
  local nowait_gesture = state.matcher:nowait_match(ctx)
  if nowait_gesture then
    state:close()
    local err = nowait_gesture:execute(ctx)
    if err then
      require("gesture.vendor.misclib.message").error(err)
    end
    return
  end

  local gesture = state.matcher:match(ctx)
  local has_forward_match = state.matcher:has_forward_match(ctx)
  state.view:render_input(ctx.inputs, gesture, has_forward_match, opts.show_board)
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
  local gesture = state.matcher:match(ctx)
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

function M.register(info)
  require("gesture.core.gesture").register(info)
end

function M.clear()
  require("gesture.core.gesture").clear()
end

return M
