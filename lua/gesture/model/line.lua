local M = {}

M.x_length_threshold = 5
M.y_length_threshold = 5

local Line = {}
Line.__index = Line
M.Line = Line

function Line.new(direction, length)
  vim.validate({direction = {direction, "string"}, length = {length, "number"}})
  local tbl = {direction = direction, length = length}
  return setmetatable(tbl, Line)
end

function Line.is_short(self)
  if self.direction == "UP" or self.direction == "DOWN" then
    return self.length < M.y_length_threshold
  end
  return self.length < M.x_length_threshold
end

return M
