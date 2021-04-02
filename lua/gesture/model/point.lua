local Line = require("gesture.model.line").Line
local listlib = require("gesture.lib.list")

local M = {}

local Point = {}
Point.__index = Point
M.Point = Point

function Point.line_to(self, point)
  local diff_x = point.x - self.x
  local length_x = math.abs(diff_x)

  local diff_y = point.y - self.y
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

local Y = function(p1, p2)
  local b = (p1.x * p2.y - p2.x * p1.y) / (p1.x - p2.x)
  local a = (p1.y - b) / p1.x
  return function(x)
    return a * x + b
  end
end

function Point.interpolate(self, point)
  local points = {}
  if self.x == point.x then
    local p1 = self
    local p2 = point
    local reverse = false
    if self.y > point.y then
      p1 = point
      p2 = self
      table.insert(points, p1)
      reverse = true
    end

    local x = p1.x
    local y = p1.y + 1
    while y < p2.y do
      table.insert(points, Point.new(x, y))
      y = y + 1
    end

    if reverse then
      return listlib.reverse(points)
    end
    table.insert(points, p2)
    return points
  end

  local p1 = self
  local p2 = point
  local reverse = false
  if self.x > point.x then
    p1 = point
    p2 = self
    reverse = true
  end
  table.insert(points, p1)

  local offset = 0.1
  local x = p1.x + offset
  local get_y = Y(p1, p2)
  while x < p2.x do
    local y = math.floor(get_y(x) + 0.5)
    local new = Point.new(math.floor(x + 0.5), y)
    local last = points[#points]
    if last.x ~= new.x or last.y ~= new.y then
      table.insert(points, new)
    end
    x = x + offset
  end

  if reverse then
    return listlib.reverse(points)
  end
  table.remove(points, 1)
  table.insert(points, p2)
  return points
end

function Point.new(x, y)
  local tbl = {x = x, y = y}
  return setmetatable(tbl, Point)
end

return M
