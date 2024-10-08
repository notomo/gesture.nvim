--- @class GestureInputDefinitions
--- @field _definitions GestureInputDefinition[]
local InputDefinitions = {}
InputDefinitions.__index = InputDefinitions

--- @param raw_input_definitions GestureInputDefinition[]
function InputDefinitions.new(raw_input_definitions)
  local tbl = {
    _definitions = raw_input_definitions,
  }
  return setmetatable(tbl, InputDefinitions)
end

function InputDefinitions.match(self, inputs)
  if #inputs ~= #self._definitions then
    return false
  end

  for i, input_definition in ipairs(self._definitions) do
    local input = inputs[i]
    if not input then
      return false
    end
    ---@diagnostic disable-next-line: invisible
    if not input_definition:match(input) then
      return false
    end
  end
  return true
end

function InputDefinitions.has_forward_match(self, inputs)
  if #inputs > #self._definitions then
    return false
  end

  for i, definition in ipairs(self._definitions) do
    local input = inputs[i]
    if not input then
      return true
    end
    ---@diagnostic disable-next-line: invisible
    if not definition:match(input) then
      return false
    end
  end
  return true
end

function InputDefinitions.strings(self)
  return vim
    .iter(self._definitions)
    :map(function(input_definition)
      return input_definition.value
    end)
    :totable()
end

--- @param nonself GestureInputDefinitions
function InputDefinitions.equals(self, nonself)
  if #nonself._definitions ~= #self._definitions then
    return false
  end

  for i, definition in ipairs(self._definitions) do
    ---@diagnostic disable-next-line: invisible
    if not definition:equals(nonself._definitions[i]) then
      return false
    end
  end
  return true
end

return InputDefinitions
