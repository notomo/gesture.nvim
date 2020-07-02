local M = {}

M.x_length_threshold = 10
M.y_length_threshold = 10

local get_length_threshold = function(direction)
  if direction == "UP" or direction == "DOWN" then
    return M.y_length_threshold
  end
  return M.x_length_threshold
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

    return {
      length = length,
      direction = direction
    }
  end

  return {
    x = x,
    y = y,
    line = line
  }
end

M.get_or_create = function()
  local state = M.get()
  if state ~= nil then
    return state, true
  end
  state = {
    last_point = nil,
    inputs = {},
    bufnr = vim.fn.bufnr("%"),
    window_bufnr = nil,
    id = nil
  }

  return state, false
end

M.save = function(window_id, window_bufnr, state)
  state.id = window_id
  state.window_bufnr = window_bufnr
  vim.api.nvim_win_set_var(window_id, "_gesture_state", state)
end

M.update = function(state)
  local x = vim.fn.wincol()
  local y = vim.fn.winline()
  local point = Point(x, y)
  if state.last_point == nil then
    state.last_point = {point.x, point.y}
  end

  local last_point = Point(unpack(state.last_point))
  local line = last_point.line(point)
  if line.direction == nil or line.length < get_length_threshold(line.direction) then
    return
  end
  state.last_point = {point.x, point.y}

  local last_input = state.inputs[#state.inputs]
  local new_input = {
    kind = "direction",
    value = line.direction,
    length = line.length
  }

  if last_input == nil or (last_input ~= nil and last_input.value ~= line.direction) then
    table.insert(state.inputs, new_input)
    return
  end

  local new_length = last_input.length + new_input.length
  table.remove(state.inputs, #state.inputs)
  table.insert(
    state.inputs,
    {
      kind = "direction",
      value = line.direction,
      length = new_length
    }
  )
end

M.get = function()
  return vim.w._gesture_state
end

return M
