local Line = require("gesture/line").Line

local M = {}

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

function Point.new(x, y)
  local tbl = {x = x, y = y}
  return setmetatable(tbl, Point)
end

function Point.from_window()
  local x = vim.fn.wincol()
  local y = vim.fn.winline()
  return Point.new(x, y)
end

M.Point = Point

return M
