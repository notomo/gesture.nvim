local Direction = require("gesture.model.direction").Direction

local M = {}

--- Draw a gesture line.
function M.draw()
  return require("gesture.command").Command.new("draw")
end

--- Finish the gesture and execute matched action.
function M.finish()
  return require("gesture.command").Command.new("finish")
end

--- Cancel the gesture.
function M.cancel()
  return require("gesture.command").Command.new("cancel")
end

--- Register a gesture.
--- @param info table: |gesture.nvim-gesture-info|
function M.register(info)
  return require("gesture.command").Command.new("register", info)
end

--- Clear the registered gestures.
function M.clear()
  return require("gesture.command").Command.new("clear")
end

--- Up input
--- @param opts table|nil: |gesture.nvim-input-opts|
function M.up(opts)
  return Direction.up(opts)
end

--- Down input
--- @param opts table|nil: |gesture.nvim-input-opts|
function M.down(opts)
  return Direction.down(opts)
end

--- Right input
--- @param opts table|nil: |gesture.nvim-input-opts|
function M.right(opts)
  return Direction.right(opts)
end

--- Left input
--- @param opts table|nil: |gesture.nvim-input-opts|
function M.left(opts)
  return Direction.left(opts)
end

return M
