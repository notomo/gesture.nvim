local Direction = require("gesture/direction").Direction
local Gesture = require("gesture/gesture").Gesture
local GestureMap = require("gesture/gesture").GestureMap

local M = {}

M.register = function(info)
  M.map:add(Gesture.new(info))
end

M.clear = function()
  M.map = GestureMap.new()
end
M.clear()

M.up = function(opts)
  return Direction.up(opts)
end

M.down = function(opts)
  return Direction.down(opts)
end

M.right = function(opts)
  return Direction.right(opts)
end

M.left = function(opts)
  return Direction.left(opts)
end

return M
