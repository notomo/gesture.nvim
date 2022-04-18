local M = {}

--- Draw a gesture line.
function M.draw()
  return require("gesture.command").draw()
end

--- Finish the gesture and execute matched action.
function M.finish()
  return require("gesture.command").finish()
end

--- Cancel the gesture.
function M.cancel()
  return require("gesture.command").cancel()
end

--- Register a gesture.
--- @param info table: |gesture.nvim-gesture-info|
function M.register(info)
  return require("gesture.command").register(info)
end

--- Clear the registered gestures.
function M.clear()
  return require("gesture.command").clear()
end

--- Up input
--- @param opts table|nil: |gesture.nvim-input-opts|
function M.up(opts)
  return require("gesture.model.direction").up(opts)
end

--- Down input
--- @param opts table|nil: |gesture.nvim-input-opts|
function M.down(opts)
  return require("gesture.model.direction").down(opts)
end

--- Right input
--- @param opts table|nil: |gesture.nvim-input-opts|
function M.right(opts)
  return require("gesture.model.direction").right(opts)
end

--- Left input
--- @param opts table|nil: |gesture.nvim-input-opts|
function M.left(opts)
  return require("gesture.model.direction").left(opts)
end

return M
