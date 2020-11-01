local repository = require("gesture/repository")
local views = require("gesture/view")
local mappers = require("gesture/mapper")
local Point = require("gesture/point").Point
local Inputs = require("gesture/input").Inputs

local M = {}

local L = function(p1, p2)
  local b = (p1.x * p2.y - p2.x * p1.y) / (p1.x - p2.x)
  local a = (p1.y - b) / p1.x
  return function(x)
    return a * x + b
  end
end

local get_points = function(point1, point2)
  local points = {}
  if point1.x == point2.x then
    local p1 = point1
    local p2 = point2
    local reverse = false
    if point1.y > point2.y then
      p1 = point2
      p2 = point1
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
      return vim.fn.reverse(points)
    end
    table.insert(points, p2)
    return points
  end

  local p1 = point1
  local p2 = point2
  local reverse = false
  if point1.x > point2.x then
    p1 = point2
    p2 = point1
    reverse = true
  end
  table.insert(points, p1)

  local offset = 0.1
  local x = p1.x + offset
  local get_y = L(p1, p2)
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

  local point = Point.from_window()
  local last = self.view._new_points[#self.view._new_points] or self._last_point
  self.view._new_points = get_points(last, point)

  local line = self._last_point:line_to(point)
  if line == nil or line:is_short() then
    return true
  end
  self._last_point = point

  local new_input = {kind = "direction", value = line.direction, length = line.length}
  self.inputs:add(new_input)

  return true
end

M.get_or_create = function()
  local current_state = M.get()
  if current_state ~= nil then
    return current_state
  end

  local mapper = mappers.new(vim.fn.bufnr("%"))
  local view = views.open()
  M.click()

  local tbl = {
    _last_point = Point.from_window(),
    inputs = Inputs.new(),
    view = view,
    mapper = mapper,
  }
  local state = setmetatable(tbl, State)

  repository.set(state.view.window_id, state)

  return state
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
