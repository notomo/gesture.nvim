local vim = vim

local M = {}

function M.add_direction(inputs, direction, length, suspended)
  local input = {
    direction = direction,
    length = length,
  }
  local last = inputs[#inputs]
  if not last or last.direction ~= input.direction or suspended then
    table.insert(inputs, input)
    return
  end
  last.length = last.length + input.length
end

function M.strings(inputs)
  return vim.tbl_map(function(input)
    return input.direction
  end, inputs)
end

return M
