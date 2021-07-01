local GestureMap = require("gesture.model.gesture").GestureMap
local Gesture = require("gesture.model.gesture").Gesture

local M = {}

M.map = GestureMap.new()

function M.clear()
  M.map = GestureMap.new()
end

function M.register(info)
  M.map:add(Gesture.new(info))
end

return M
