local vim = vim

local Inputs = {}
Inputs.__index = Inputs

function Inputs.new()
  local tbl = {
    _inputs = {},
    _suspend = false,
  }
  return setmetatable(tbl, Inputs)
end

function Inputs.add_direction(self, direction, length)
  local direction_input = {
    value = direction,
    length = length,
  }
  self:_add(direction_input)
end

function Inputs._add(self, input)
  vim.validate({ input = { input, "table" } })
  local last = self._inputs[#self._inputs]
  if not last or last.value ~= input.value or self._suspend then
    self._suspend = false
    table.insert(self._inputs, input)
    return
  end
  last.length = last.length + input.length
end

function Inputs.suspend(self)
  self._suspend = true
end

function Inputs.index(self, i)
  return self._inputs[i]
end

function Inputs.values(self)
  return vim.tbl_map(function(input)
    return input.value
  end, self._inputs)
end

function Inputs.is_empty(self)
  return #self._inputs == 0
end

return Inputs
