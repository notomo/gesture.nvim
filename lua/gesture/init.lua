local Direction = require("gesture.model.direction").Direction
local Gesture = require("gesture.model.gesture").Gesture
local GestureMap = require("gesture.model.gesture").GestureMap

local M = {}

function M.draw()
  return require("gesture.command").Command.new("draw")
end

function M.finish()
  return require("gesture.command").Command.new("finish")
end

function M.cancel()
  return require("gesture.command").Command.new("cancel")
end

function M.register(info)
  M.map:add(Gesture.new(info))
end

function M.clear()
  M.map = GestureMap.new()
end
M.clear()

function M.up(opts)
  return Direction.up(opts)
end

function M.down(opts)
  return Direction.down(opts)
end

function M.right(opts)
  return Direction.right(opts)
end

function M.left(opts)
  return Direction.left(opts)
end

return M
