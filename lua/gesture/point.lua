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

local Point = {}
Point.__index = Point

function Point.line_to(self, point)
  local x1 = self.x
  local x2 = point.x
  local diff_x = x2 - x1
  local length_x = math.abs(diff_x)

  local y1 = self.y
  local y2 = point.y
  local diff_y = y2 - y1
  local length_y = math.abs(diff_y)

  local direction, length
  if length_x > length_y then
    direction = diff_x > 0 and "RIGHT" or "LEFT"
    length = length_x
  elseif length_y >= length_x and length_y > 0 then
    direction = diff_y > 0 and "DOWN" or "UP"
    length = length_y
  else
    return nil
  end

  return Line.new(direction, length)
end

M.new = function(x, y)
  local tbl = {x = x, y = y}
  return setmetatable(tbl, Point)
end

return M
