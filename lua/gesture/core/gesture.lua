local Inputs = require("gesture.core.input").Inputs
local vim = vim

local M = {}

local Gesture = {}
Gesture.__index = Gesture
M.Gesture = Gesture

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
    action = {
      info.action,
      function(x)
        return type(x) == "string" or is_callable
      end,
      "string or callable",
    },
    inputs = {
      info.inputs,
      function(inputs)
        return #inputs ~= 0
      end,
      "not empty",
    },
    nowait = { info.nowait, "boolean", true },
    buffer = {
      info.buffer,
      function(buffer)
        local typ = type(buffer)
        return typ == "nil" or typ == "string" or typ == "number"
      end,
      "nil or string or number",
    },
  })

  local bufnr = nil
  if info.buffer then
    bufnr = vim.fn.bufnr(info.buffer)
  end

  local tbl = {
    name = info.name or "",
    inputs = Inputs.new(info.inputs),
    nowait = info.nowait or false,
    buffer = bufnr,
    _action = action,
  }
  return setmetatable(tbl, Gesture)
end

function Gesture.execute(self, param)
  local ok, result = pcall(self._action, param)
  if not ok then
    return result
  end
  return nil
end

function Gesture.has_forward_match(self, inputs)
  local i = 1
  for _, def in self.inputs:iter() do
    local input = inputs[i]
    if not input then
      return true
    end
    if not def:match(input) then
      return false
    end
  end
  return true
end

function Gesture.match(self, inputs)
  local i = 1
  for _, def in self.inputs:iter() do
    local input = inputs[i]
    if not def:match(input) then
      return false
    end
  end
  return true
end

local Gestures = {}
Gestures.__index = Gestures

function Gestures.new()
  local tbl = { _gestures = {} }
  return setmetatable(tbl, Gestures)
end

function Gestures.add(self, gesture)
  for i, g in ipairs(self._gestures) do
    if gesture.inputs == g.inputs then
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

function Gestures.match(self, inputs)
  for _, gesture in ipairs(self._gestures) do
    if gesture:match(inputs) then
      return gesture
    end
  end
  return nil
end

local GestureMap = {}
GestureMap.__index = GestureMap
M.GestureMap = GestureMap

function GestureMap.new()
  local tbl = {
    _map = {},
  }
  return setmetatable(tbl, GestureMap)
end

local make_key = function(bufnr, nowait, inputs)
  local elements = {
    tostring(bufnr),
    tostring(nowait),
    inputs:identify(),
  }
  return table.concat(elements, "\t")
end

function GestureMap.add(self, gesture)
  vim.validate({ gesture = { gesture, "table" } })
  local key = make_key(gesture.buffer, gesture.nowait, gesture.inputs)
  local gestures = self._map[key] or Gestures.new()
  gestures:add(gesture)
  self._map[key] = gestures
end

function GestureMap.match(self, bufnr, inputs, nowait)
  vim.validate({
    bufnr = { bufnr, "number" },
    nowait = { nowait, "boolean" },
  })

  local buffer_key = make_key(bufnr, nowait, inputs)
  local buffer_gestures = self._map[buffer_key]
  if buffer_gestures then
    local gesture = buffer_gestures:match(inputs)
    if gesture then
      return gesture
    end
  end

  local global_key = make_key(nil, nowait, inputs)
  local global_gestures = self._map[global_key]
  if global_gestures then
    return global_gestures:match(inputs)
  end
  return nil
end

function GestureMap.has_forward_match(self, bufnr, inputs)
  vim.validate({ bufnr = { bufnr, "number" } })

  local buffer_nowait_key = make_key(bufnr, true, inputs)
  local buffer_key = make_key(bufnr, false, inputs)
  for key, gestures in pairs(self._map) do
    local key_matched = vim.startswith(key, buffer_nowait_key) or vim.startswith(key, buffer_key)
    if key_matched and gestures:has_forward_match(inputs) then
      return true
    end
  end

  local nowait_key = make_key(nil, true, inputs)
  local global_key = make_key(nil, false, inputs)
  for key, gestures in pairs(self._map) do
    local key_matched = vim.startswith(key, nowait_key) or vim.startswith(key, global_key)
    if key_matched and gestures:has_forward_match(inputs) then
      return true
    end
  end

  return false
end

return M
