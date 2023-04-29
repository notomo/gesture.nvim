local Direction = {}
Direction.__index = Direction

local Directions = {
  UP = "UP",
  DOWN = "DOWN",
  RIGHT = "RIGHT",
  LEFT = "LEFT",
}

local new = function(typ, opts)
  vim.validate({
    typ = {
      typ,
      function(t)
        return Directions[t]
      end,
      vim.inspect(Directions),
    },
    opts = { opts, "table", true },
  })

  opts = opts or {}

  vim.validate({
    max_length = { opts.max_length, "number", true },
    min_length = { opts.min_length, "number", true },
  })

  local tbl = {
    value = typ,
    max_length = opts.max_length,
    min_length = opts.min_length,
  }
  return setmetatable(tbl, Direction)
end

function Direction.match(self, input)
  if self.max_length and self.max_length < input.length then
    return false
  end
  if self.min_length and self.min_length > input.length then
    return false
  end
  return true
end

function Direction.up(opts)
  return new(Directions.UP, opts)
end

function Direction.down(opts)
  return new(Directions.DOWN, opts)
end

function Direction.right(opts)
  return new(Directions.RIGHT, opts)
end

function Direction.left(opts)
  return new(Directions.LEFT, opts)
end

function Direction.equals(self, direction)
  return self.value == direction.value
    and self.max_length == direction.max_length
    and self.min_length == direction.min_length
end

return Direction
