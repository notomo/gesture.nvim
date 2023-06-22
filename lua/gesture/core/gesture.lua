local vim = vim

local M = {}

local Gesture = {}
Gesture.__index = Gesture

function Gesture.new(info)
  vim.validate({ info = { info, "table" } })

  local is_callable = vim.is_callable(info.action)
  local action
  if is_callable then
    action = info.action
  else
    action = function()
      vim.cmd(info.action)
    end
  end

  vim.validate({
    name = { info.name, "string", true },
    action = { info.action, { "string", "callable" } },
    inputs = { info.inputs, "table", true },
    match = { info.match, "function", true },
    can_match = { info.can_match, "function", true },
    nowait = { info.nowait, "boolean", true },
    buffer = { info.buffer, { "string", "number" }, true },
  })

  local bufnr = nil
  if info.buffer then
    bufnr = vim.fn.bufnr(info.buffer)
  end

  local input_defs
  if not info.match then
    input_defs = require("gesture.core.input_definitions").new(info.inputs or {})
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
    name = info.name or "",
    input_defs = input_defs,
    _match = info.match,
    can_match = can_match,
    nowait = info.nowait or false,
    buffer = bufnr,
    _action = action,
  }
  return setmetatable(tbl, Gesture)
end

function Gesture.match(self, ctx)
  if not self._match then
    return self.input_defs:match(ctx.inputs)
  end
  return self._match(ctx)
end

function Gesture.execute(self, ctx)
  local ok, result = pcall(self._action, ctx)
  if not ok then
    return result
  end
  return nil
end

local Gestures = {}
Gestures.__index = Gestures

function Gestures.new()
  local tbl = { _gestures = {} }
  return setmetatable(tbl, Gestures)
end

function Gestures.add(self, gesture)
  for i, g in ipairs(self._gestures) do
    if gesture._match and gesture.name == g.name then
      self._gestures[i] = gesture
      return
    end
    if gesture.input_defs:equals(g.input_defs) then
      self._gestures[i] = gesture
      return
    end
  end
  table.insert(self._gestures, gesture)
end

function Gestures.can_match(self, ctx)
  for _, gesture in ipairs(self._gestures) do
    if gesture.can_match(ctx) then
      return true
    end
  end
  return false
end

function Gestures.match(self, ctx)
  for _, gesture in ipairs(self._gestures) do
    if gesture:match(ctx) then
      return gesture
    end
  end
  return nil
end

local GestureMap = {}
GestureMap.__index = GestureMap

function GestureMap.new()
  local tbl = {
    _map = {},
  }
  return setmetatable(tbl, GestureMap)
end

local make_key = function(bufnr, nowait, input_strs)
  local elements = {
    tostring(bufnr),
    tostring(nowait),
    table.concat(input_strs, "-"),
  }
  return table.concat(elements, "\t")
end

local for_match_strs = { "_" }

function GestureMap.add(self, gesture)
  vim.validate({ gesture = { gesture, "table" } })
  local strs
  if gesture.input_defs then
    strs = gesture.input_defs:strings()
  else
    strs = for_match_strs
  end
  local key = make_key(gesture.buffer, gesture.nowait, strs)
  local gestures = self._map[key] or Gestures.new()
  gestures:add(gesture)
  self._map[key] = gestures
end

function GestureMap.match(self, bufnr, ctx, nowait)
  vim.validate({
    bufnr = { bufnr, "number" },
    nowait = { nowait, "boolean" },
  })
  local input_strs = require("gesture.core.inputs").strings(ctx.inputs)

  local keys = {
    make_key(bufnr, nowait, for_match_strs),
    make_key(bufnr, nowait, input_strs),
    make_key(nil, nowait, for_match_strs),
    make_key(nil, nowait, input_strs),
  }
  for _, key in ipairs(keys) do
    local gesture = self:_match(key, ctx)
    if gesture then
      return gesture
    end
  end

  return nil
end

function GestureMap._match(self, key, ctx)
  local gestures = self._map[key]
  if not gestures then
    return nil
  end
  return gestures:match(ctx)
end

function GestureMap.can_match(self, bufnr, ctx)
  vim.validate({ bufnr = { bufnr, "number" } })
  local input_strs = require("gesture.core.inputs").strings(ctx.inputs)

  local key_pairs = {
    {
      make_key(bufnr, true, for_match_strs),
      make_key(bufnr, false, for_match_strs),
    },
    {
      make_key(bufnr, true, input_strs),
      make_key(bufnr, false, input_strs),
    },
    {
      make_key(nil, true, for_match_strs),
      make_key(nil, false, for_match_strs),
    },
    {
      make_key(nil, true, input_strs),
      make_key(nil, false, input_strs),
    },
  }
  for _, key_pair in ipairs(key_pairs) do
    local matched = self:_can_match(key_pair[1], key_pair[2], ctx)
    if matched then
      return matched
    end
  end

  return false
end

function GestureMap._can_match(self, nowait_key, key, ctx)
  for k, gestures in pairs(self._map) do
    local key_matched = vim.startswith(key, nowait_key) or vim.startswith(k, key)
    if key_matched and gestures:can_match(ctx) then
      return true
    end
  end
  return false
end

M.map = GestureMap.new()

function M.clear()
  M.map = GestureMap.new()
end

function M.register(info)
  M.map:add(Gesture.new(info))
end

return M
