local InputDefinitions = {}
InputDefinitions.__index = InputDefinitions

function InputDefinitions.new(raw_input_definitions)
  vim.validate({ raw_input_definitions = { raw_input_definitions, "table" } })
  local tbl = {
    _definitions = raw_input_definitions,
  }
  return setmetatable(tbl, InputDefinitions)
end

function InputDefinitions.match(self, inputs)
  for i, input_definition in ipairs(self._definitions) do
    local input = inputs[i]
    if not input then
      return false
    end
    if not input_definition:match(input) then
      return false
    end
  end
  return true
end

function InputDefinitions.has_forward_match(self, inputs)
  for i, definition in ipairs(self._definitions) do
    local input = inputs[i]
    if not input then
      return true
    end
    if not definition:match(input) then
      return false
    end
  end
  return true
end

function InputDefinitions.strings(self)
  return vim.tbl_map(function(input_definition)
    return input_definition.value
  end, self._definitions)
end

function InputDefinitions.equals(self, nonself)
  for i, definition in ipairs(self._definitions) do
    if not definition:equals(nonself._definitions[i]) then
      return false
    end
  end
  return true
end

return InputDefinitions
