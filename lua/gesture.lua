local M = {}

M.register = function(info)
  local gesture =
    info or
    {
      name = "",
      action = nil,
      inputs = {},
      nowait = false,
      buffer = nil
    }
  if gesture.action == nil or gesture.inputs == {} then
    return
  end

  local lhss = {}
  for _, input in ipairs(gesture.inputs) do
    table.insert(lhss, input.value)
  end
  local lhs = table.concat(lhss, "-")

  if gesture.buffer ~= nil then
    local bufnr = vim.fn.bufnr(gesture.buffer)
    local buffer_gestures = M.buffer[bufnr]
    if buffer_gestures == nil then
      M.buffer[bufnr] = {}
    end
    local gestures = M.buffer[bufnr][lhs]
    if gestures == nil then
      M.buffer[bufnr][lhs] = {}
    end
    table.insert(M.buffer[bufnr][lhs], gesture)
  else
    local gestures = M.global[lhs]
    if gestures == nil then
      M.global[lhs] = {}
    end
    table.insert(M.global[lhs], gesture)
  end
end

M.global = {}
M.buffer = {}

M.clear = function()
  M.global = {}
  M.buffer = {}
end

local to_direction = function(direction, info)
  local direction_info = info or {}
  return {
    kind = "direction",
    value = direction,
    max_length = direction_info.max_length,
    min_length = direction_info.min_length
  }
end

M.up = function(info)
  return to_direction("UP", info)
end

M.down = function(info)
  return to_direction("DOWN", info)
end

M.right = function(info)
  return to_direction("RIGHT", info)
end

M.left = function(info)
  return to_direction("LEFT", info)
end

return M
