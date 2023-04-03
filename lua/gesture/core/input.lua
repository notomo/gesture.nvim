local vim = vim

local M = {}

local Input = {}
Input.__index = Input
M.Input = Input

function Input.direction(direction, length)
  vim.validate({
    direction = { direction, "string" },
    length = { length, "number" },
  })
  local tbl = {
    value = direction,
    length = length,
  }
  return setmetatable(tbl, Input)
end

local Inputs = {}
Inputs.__index = function(self, k)
  if type(k) == "number" then
    return self._inputs[k]
  end
  return Inputs[k]
end
M.Inputs = Inputs

function Inputs.new(inputs)
  vim.validate({ inputs = { inputs, "table", true } })
  local tbl = {
    _inputs = inputs or {},
    _suspend = false,
  }
  return setmetatable(tbl, Inputs)
end

function Inputs.add(self, input)
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

function Inputs.values(self)
  return vim.tbl_map(function(input)
    return input.value
  end, self._inputs)
end

function Inputs.iter(self)
  return next, self._inputs, nil
end

function Inputs.is_empty(self)
  return #self._inputs == 0
end

function Inputs.identify(self)
  local ids = vim.tbl_map(function(input)
    return input.value
  end, self._inputs)
  return table.concat(ids, "-")
end

function Inputs.__eq(a, b)
  if a:identify() ~= b:identify() then
    return false
  end
  for i, input in a:iter() do
    if input ~= b[i] then
      return false
    end
  end
  return true
end

return M
