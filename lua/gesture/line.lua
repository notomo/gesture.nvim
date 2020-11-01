local M = {}

M.x_length_threshold = 5
M.y_length_threshold = 5

local Line = {}
Line.__index = Line

function Line.new(direction, length)
  local tbl = {direction = direction, length = length}
  return setmetatable(tbl, Line)
end

function Line.is_short(self)
  local length_threshold
  if self.direction == "UP" or self.direction == "DOWN" then
    length_threshold = M.y_length_threshold
  else
    length_threshold = M.x_length_threshold
  end
  return self.length < length_threshold
end

M.Line = Line

return M
