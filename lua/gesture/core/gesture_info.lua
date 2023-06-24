local vim = vim

local GestureInfo = {}
GestureInfo.__index = GestureInfo

function GestureInfo.new(info)
  vim.validate({ info = { info, "table" } })

  vim.validate({
    name = { info.name, "string", true },
    action = { info.action, { "string", "callable" } },
    inputs = { info.inputs, "table", true },
    match = { info.match, "function", true },
    can_match = { info.can_match, "function", true },
    nowait = { info.nowait, "boolean", true },
    buffer = { info.buffer, { "string", "number" }, true },
  })

  local is_callable = vim.is_callable(info.action)
  local action
  if is_callable then
    action = info.action
  else
    action = function()
      vim.cmd(info.action)
    end
  end

  local bufnr = nil
  if info.buffer then
    bufnr = vim.fn.bufnr(info.buffer)
  end

  local name = info.name or ""

  local input_defs
  local strs
  local match
  local equals
  if info.match then
    strs = nil
    match = info.match
    equals = function(g)
      return name == g.name
    end
  else
    input_defs = require("gesture.core.input_definitions").new(info.inputs or {})
    strs = input_defs:strings()
    match = function(ctx)
      return input_defs:match(ctx.inputs)
    end
    equals = function(g)
      return input_defs:equals(g._input_defs)
    end
  end

  local can_match
  if info.can_match then
    can_match = info.can_match
  elseif info.match then
    can_match = function(_)
      return true
    end
  elseif input_defs then
    can_match = function(ctx)
      return input_defs:has_forward_match(ctx.inputs)
    end
  end

  local tbl = {
    name = name,
    match = match,
    can_match = can_match,
    equals = equals,
    nowait = info.nowait or false,
    buffer = bufnr,
    strs = strs,
    _action = action,
    _input_defs = input_defs,
  }
  return setmetatable(tbl, GestureInfo)
end

function GestureInfo.execute(self, ctx)
  local ok, result = pcall(self._action, ctx)
  if not ok then
    return result
  end
  return nil
end

return GestureInfo
