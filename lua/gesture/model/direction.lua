local M = {}

local Direction = {}
Direction.__index = Direction
M.Direction = Direction

local types = {UP = "UP", DOWN = "DOWN", RIGHT = "RIGHT", LEFT = "LEFT"}

function Direction._new(typ, opts)
  vim.validate {
    typ = {
      typ,
      function(t)
        return types[t] ~= nil
      end,
      vim.inspect(types),
    },
    opts = {opts, "table", true},
  }
  opts = opts or {}
  vim.validate({
    max_length = {opts.max_length, "number", true},
    min_length = {opts.min_length, "number", true},
  })

  local tbl = {
    kind = "direction",
    value = typ,
    max_length = opts.max_length,
    min_length = opts.min_length,
  }
  return setmetatable(tbl, Direction)
end

function Direction.up(opts)
  return Direction._new(types.UP, opts)
end

function Direction.down(opts)
  return Direction._new(types.DOWN, opts)
end

function Direction.right(opts)
  return Direction._new(types.RIGHT, opts)
end

function Direction.left(opts)
  return Direction._new(types.LEFT, opts)
end

function Direction.__eq(a, b)
  return a.kind == b.kind and a.value == b.value and a.max_length == b.max_length and a.min_length == b.min_length
end

return M
