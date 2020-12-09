local Inputs = require("gesture/model/input").Inputs

local M = {}

local Gesture = {}
Gesture.__index = Gesture
M.Gesture = Gesture

function Gesture.new(info)
  vim.validate({info = {info, "table"}})
  vim.validate({
    action = {info.action, "string"},
    inputs = {
      info.inputs,
      function(inputs)
        return #inputs ~= 0
      end,
      "not empty",
    },
  })

  local tbl = {
    name = info.name or "",
    action = info.action,
    inputs = Inputs.new(info.inputs),
    nowait = info.nowait or false,
    buffer = info.buffer,
  }
  return setmetatable(tbl, Gesture)
end

function Gesture.execute(self)
  return vim.fn.execute(self.action)
end

function Gesture.match(self, inputs, nowait)
  if nowait and not self.nowait then
    return false
  end

  local i = 1
  for _, def in self.inputs:iter() do
    local input = inputs[i]
    if def.max_length ~= nil and def.max_length < input.length then
      return false
    end
    if def.min_length ~= nil and def.min_length > input.length then
      return false
    end
  end

  return true
end

local Gestures = {}
Gestures.__index = Gestures
M.Gestures = Gestures

function Gestures.new()
  local tbl = {_gestures = {}}
  return setmetatable(tbl, Gestures)
end

function Gestures.add(self, gesture)
  local lhs = gesture.inputs:identify()
  if self._gestures[lhs] == nil then
    self._gestures[lhs] = {}
  end
  table.insert(self._gestures[lhs], gesture)
end

function Gestures.has_forward_match(self, inputs)
  local lhs = inputs:identify()
  for key in pairs(self._gestures) do
    if vim.startswith(key, lhs) then
      return true
    end
  end
  return false
end

function Gestures.match(self, inputs, nowait)
  local lhs = inputs:identify()
  local gs = self._gestures[lhs]
  if gs == nil then
    return nil
  end

  for _, gesture in ipairs(gs) do
    if gesture:match(inputs, nowait) then
      return gesture
    end
  end

  return nil
end

local GestureMap = {}
GestureMap.__index = GestureMap
M.GestureMap = GestureMap

function GestureMap.new()
  local tbl = {_global = Gestures.new(), _buffer_local = {}}
  return setmetatable(tbl, GestureMap)
end

function GestureMap.add(self, gesture)
  vim.validate({gesture = {gesture, "table"}})

  if gesture.buffer ~= nil then
    local bufnr = vim.fn.bufnr(gesture.buffer)
    local buffer_gestures = self._buffer_local[bufnr]
    if buffer_gestures == nil then
      self._buffer_local[bufnr] = Gestures.new()
    end
    self._buffer_local[bufnr]:add(gesture)
  else
    self._global:add(gesture)
  end
end

function GestureMap.match(self, bufnr, inputs, nowait)
  vim.validate({bufnr = {bufnr, "number"}, nowait = {nowait, "boolean"}})
  local gestures = self._buffer_local[bufnr]
  if gestures ~= nil then
    return gestures:match(inputs, nowait) or self._global:match(inputs, nowait)
  end
  return self._global:match(inputs, nowait)
end

function GestureMap.has_forward_match(self, bufnr, inputs)
  vim.validate({bufnr = {bufnr, "number"}})
  local gestures = self._buffer_local[bufnr]
  if gestures ~= nil then
    return gestures:has_forward_match(inputs) or self._global:has_forward_match(inputs)
  end
  return self._global:has_forward_match(inputs)
end

return M
