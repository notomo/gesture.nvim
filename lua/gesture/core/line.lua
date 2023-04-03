local Line = {}
Line.__index = Line

function Line.new(direction, length)
  vim.validate({
    direction = { direction, "string" },
    length = { length, "number" },
  })
  local tbl = {
    direction = direction,
    length = length,
  }
  return setmetatable(tbl, Line)
end

local Direction = require("gesture.core.direction")
local UP = Direction.up().value
local DOWN = Direction.down().value

function Line.is_short(self, length_thresholds)
  if self.direction == UP or self.direction == DOWN then
    return self.length < length_thresholds.y
  end
  return self.length < length_thresholds.x
end

return Line
