local vim = vim

local M = {}

function M.add_direction(inputs, input, suspended)
  local last = inputs[#inputs]
  if not last or last.direction ~= input.direction or suspended then
    table.insert(inputs, input)
    return
  end
  last.length = last.length + input.length
end

function M.strings(inputs)
  return vim
    .iter(inputs)
    :map(function(input)
      return input.direction
    end)
    :totable()
end

return M
