local InputDefinitions = {}
InputDefinitions.__index = InputDefinitions

function InputDefinitions.new(defs)
  vim.validate({ defs = { defs, "table" } })
  local tbl = {
    _defs = defs or {},
  }
  return setmetatable(tbl, InputDefinitions)
end

function InputDefinitions.match(self, inputs)
  for i, def in ipairs(self._defs) do
    local input = inputs:index(i)
    if not input then
      return false
    end
    if not def:match(input) then
      return false
    end
  end
  return true
end

function InputDefinitions.has_forward_match(self, inputs)
  for i, def in ipairs(self._defs) do
    local input = inputs:index(i)
    if not input then
      return true
    end
    if not def:match(input) then
      return false
    end
  end
  return true
end

function InputDefinitions.values(self)
  return vim.tbl_map(function(def)
    return def.value
  end, self._defs)
end

function InputDefinitions.equals(self, input_defs)
  for i, def in ipairs(self._defs) do
    if not def:equals(input_defs._defs[i]) then
      return false
    end
  end
  return true
end

return InputDefinitions
