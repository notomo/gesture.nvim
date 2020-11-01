local repository = require("gesture/repository")
local views = require("gesture/view")
local mappers = require("gesture/mapper")
local Point = require("gesture/point")
local Inputs = require("gesture/input").Inputs

local M = {}

local L = function(p1, p2)
  local x1 = p1[1]
  local y1 = p1[2]
  local x2 = p2[1]
  local y2 = p2[2]

  local b = (x1 * y2 - x2 * y1) / (x1 - x2)
  local a = (y1 - b) / x1
  return function(x)
    return a * x + b
  end, nil
end

local get_points = function(point1, point2)
  if point1[1] == point2[1] and point1[2] == point2[2] then
    return {}
  end

  local points = {}
  if point1[1] == point2[1] then
    local p1 = point1
    local p2 = point2
    local reverse = false
    if point1[2] > point2[2] then
      p1 = point2
      p2 = point1
      table.insert(points, p1)
      reverse = true
    end

    local x = p1[1]
    local y = p1[2] + 1
    while y < p2[2] do
      table.insert(points, {x, y})
      y = y + 1
    end

    if reverse then
      return vim.fn.reverse(points)
    end
    table.insert(points, p2)
    return points
  end

  local p1 = point1
  local p2 = point2
  local reverse = false
  if point1[1] > point2[1] then
    p1 = point2
    p2 = point1
    reverse = true
  end
  table.insert(points, p1)

  local offset = 0.1
  local x = p1[1] + offset
  local get_y = L(p1, p2)
  while x < p2[1] do
    local y = math.floor(get_y(x) + 0.5)
    local new = {math.floor(x + 0.5), y}
    local last = points[#points]
    if last[1] ~= new[1] or last[2] ~= new[2] then
      table.insert(points, new)
    end
    x = x + offset
  end

  if reverse then
    return vim.fn.reverse(points)
  end
  table.remove(points, 1)
  table.insert(points, p2)
  return points
end

local State = {}
State.__index = State

function State.update(self)
  M.click()

  if not self.view:is_valid() then
    return false
  end

  local x = vim.fn.wincol()
  local y = vim.fn.winline()
  local point = Point.new(x, y)
  local raw_point = {point.x, point.y}
  if self._last_point == nil then
    self._last_point = raw_point
    self.view._new_points = {raw_point}
  else
    local last_raw_point = self.view._new_points[#self.view._new_points] or self._last_point
    self.view._new_points = get_points(last_raw_point, raw_point)
  end

  local last_point = Point.new(unpack(self._last_point))
  local line = last_point:line_to(point)
  if line == nil or line:is_short() then
    return true
  end
  self._last_point = {point.x, point.y}

  local new_input = {kind = "direction", value = line.direction, length = line.length}
  self.inputs:add(new_input)

  return true
end

M.get_or_create = function()
  local state = M.get()
  if state ~= nil then
    return state
  end

  local mapper = mappers.new(vim.fn.bufnr("%"))
  local tbl = {_last_point = nil, inputs = Inputs.new(), view = views.open(), mapper = mapper}
  local self = setmetatable(tbl, State)

  repository.set(self.view.window_id, self)

  return self
end

M.get = function()
  return repository.get(vim.api.nvim_get_current_win())
end

local mouse = vim.api.nvim_eval("\"\\<LeftMouse>\"")
-- replace on testing
M.click = function()
  vim.api.nvim_command("normal! " .. mouse)
end

return M
