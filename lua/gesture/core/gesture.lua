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

  local tbl = {
    name = info.name or "",
    input_defs = input_defs,
    _match = info.match,
    nowait = info.nowait or false,
    buffer = bufnr,
    _action = action,
  }
  return setmetatable(tbl, Gesture)
end

function Gesture.match(self, ctx, inputs)
  if not self._match then
    return self.input_defs:match(inputs)
  end
  return self._match(ctx)
end

function Gesture.has_forward_match(self, inputs)
  if not self._match then
    return self.input_defs:has_forward_match(inputs)
  end
  return true
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

function Gestures.has_forward_match(self, inputs)
  for _, gesture in ipairs(self._gestures) do
    if gesture:has_forward_match(inputs) then
      return true
    end
  end
  return false
end

function Gestures.match(self, ctx, inputs)
  for _, gesture in ipairs(self._gestures) do
    if gesture:match(ctx, inputs) then
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

local make_key = function(bufnr, nowait, input_values)
  local elements = {
    tostring(bufnr),
    tostring(nowait),
    table.concat(input_values, "-"),
  }
  return table.concat(elements, "\t")
end

local for_match_values = { "_" }

function GestureMap.add(self, gesture)
  vim.validate({ gesture = { gesture, "table" } })
  local values
  if gesture.input_defs then
    values = gesture.input_defs:values()
  else
    values = for_match_values
  end
  local key = make_key(gesture.buffer, gesture.nowait, values)
  local gestures = self._map[key] or Gestures.new()
  gestures:add(gesture)
  self._map[key] = gestures
end

function GestureMap.match(self, bufnr, ctx, inputs, nowait)
  vim.validate({
    bufnr = { bufnr, "number" },
    nowait = { nowait, "boolean" },
  })
  local input_values = inputs:values()

  local keys = {
    make_key(bufnr, nowait, for_match_values),
    make_key(nil, nowait, for_match_values),
    make_key(bufnr, nowait, input_values),
    make_key(nil, nowait, input_values),
  }
  for _, key in ipairs(keys) do
    local gesture = self:_match(key, ctx, inputs)
    if gesture then
      return gesture
    end
  end

  return nil
end

function GestureMap._match(self, key, ctx, inputs)
  local gestures = self._map[key]
  if not gestures then
    return nil
  end
  return gestures:match(ctx, inputs)
end

function GestureMap.has_forward_match(self, bufnr, inputs)
  vim.validate({ bufnr = { bufnr, "number" } })
  local input_values = inputs:values()

  local key_pairs = {
    {
      make_key(bufnr, true, for_match_values),
      make_key(bufnr, false, for_match_values),
    },
    {
      make_key(nil, true, for_match_values),
      make_key(nil, false, for_match_values),
    },
    {
      make_key(bufnr, true, input_values),
      make_key(bufnr, false, input_values),
    },
    {
      make_key(nil, true, input_values),
      make_key(nil, false, input_values),
    },
  }
  for _, key_pair in ipairs(key_pairs) do
    local matched = self:_has_forward_match(key_pair[1], key_pair[2], inputs)
    if matched then
      return matched
    end
  end

  return false
end

function GestureMap._has_forward_match(self, nowait_key, key, inputs)
  for k, gestures in pairs(self._map) do
    local key_matched = vim.startswith(key, nowait_key) or vim.startswith(k, key)
    if key_matched and gestures:has_forward_match(inputs) then
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
