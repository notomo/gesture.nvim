local DirectionInputDefinition = {}
DirectionInputDefinition.__index = DirectionInputDefinition

local new = function(value, opts)
  vim.validate({
    typ = { value, "string" },
    opts = { opts, "table", true },
  })

  opts = opts or {}

  vim.validate({
    max_length = { opts.max_length, "number", true },
    min_length = { opts.min_length, "number", true },
  })

  local tbl = {
    value = value,
    max_length = opts.max_length,
    min_length = opts.min_length,
  }
  return setmetatable(tbl, DirectionInputDefinition)
end

local Directions = require("gesture.core.directions")

function DirectionInputDefinition.up(opts)
  return new(Directions.UP, opts)
end

function DirectionInputDefinition.down(opts)
  return new(Directions.DOWN, opts)
end

function DirectionInputDefinition.right(opts)
  return new(Directions.RIGHT, opts)
end

function DirectionInputDefinition.left(opts)
  return new(Directions.LEFT, opts)
end

function DirectionInputDefinition.equals(self, input_definition)
  return self.value == input_definition.value
    and self.max_length == input_definition.max_length
    and self.min_length == input_definition.min_length
end

function DirectionInputDefinition.match(self, input)
  if self.max_length and self.max_length < input.length then
    return false
  end
  if self.min_length and self.min_length > input.length then
    return false
  end
  return true
end

return DirectionInputDefinition
