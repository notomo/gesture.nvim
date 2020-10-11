local repository = require("gesture/repository")

local M = {}

M.x_length_threshold = 5
M.y_length_threshold = 5

local get_length_threshold = function(direction)
  if direction == "UP" or direction == "DOWN" then
    return M.y_length_threshold
  end
  return M.x_length_threshold
end

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

local Point = function(x, y)
  local line = function(point)
    local x1 = x
    local x2 = point.x
    local diff_x = x2 - x1
    local length_x = math.abs(diff_x)

    local y1 = y
    local y2 = point.y
    local diff_y = y2 - y1
    local length_y = math.abs(diff_y)

    local direction = nil
    local length = 0
    if length_x > length_y then
      direction = diff_x > 0 and "RIGHT" or "LEFT"
      length = length_x
    elseif length_y >= length_x and length_y > 0 then
      direction = diff_y > 0 and "DOWN" or "UP"
      length = length_y
    end

    return {length = length, direction = direction}
  end

  return {x = x, y = y, line = line}
end

local update = function(state)
  local x = vim.fn.wincol()
  local y = vim.fn.winline()
  local point = Point(x, y)
  local raw_point = {point.x, point.y}
  if state.last_point == nil then
    state.last_point = raw_point
    state.new_points = {raw_point}
  else
    local last_raw_point = state.new_points[#state.new_points] or state.last_point
    state.new_points = get_points(last_raw_point, raw_point)
  end

  local last_point = Point(unpack(state.last_point))
  local line = last_point.line(point)
  if line.direction == nil or line.length < get_length_threshold(line.direction) then
    return
  end
  state.last_point = {point.x, point.y}

  local last_input = state.inputs[#state.inputs]
  local new_input = {kind = "direction", value = line.direction, length = line.length}

  if last_input == nil or (last_input ~= nil and last_input.value ~= line.direction) then
    table.insert(state.inputs, new_input)
    return
  end

  local new_length = last_input.length + new_input.length
  table.remove(state.inputs, #state.inputs)
  table.insert(state.inputs, {kind = "direction", value = line.direction, length = new_length})
end

M.get_or_create = function()
  local state = M.get()
  if state ~= nil then
    return state, true
  end

  local new_state = {
    last_point = nil,
    new_points = {},
    mark_store = {},
    inputs = {},
    bufnr = vim.fn.bufnr("%"),
    window = nil,
    virtualedit = vim.o.virtualedit,
  }
  new_state.update = function(window)
    new_state.window = window
    repository.set(window.id, new_state)
    update(new_state)
  end

  return new_state, false
end

M.get = function()
  return repository.get(vim.api.nvim_get_current_win())
end

return M
