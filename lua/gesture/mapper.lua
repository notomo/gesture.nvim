local gestures = require("gesture")

local M = {}

local filter_gestures = function(gesture, inputs, nowait)
  if nowait and not gesture.nowait then
    return nil
  end

  local input_defs = gesture.inputs
  local i = 1
  for _, input_def in ipairs(input_defs) do
    local input = inputs[i]
    if input_def.max_length ~= nil and input_def.max_length < input.length then
      return nil
    end
    if input_def.min_length ~= nil and input_def.min_length > input.length then
      return nil
    end
  end

  return gesture
end

local filter_gesture_map = function(gesture_map, inputs, nowait)
  local lhs = inputs:identify()
  local gs = gesture_map[lhs]
  if gs == nil then
    return nil
  end

  for _, gesture in ipairs(gs) do
    local g = filter_gestures(gesture, inputs, nowait)
    if g ~= nil then
      return g
    end
  end

  return nil
end

local Mapper = {}
Mapper.__index = Mapper
M.Mapper = Mapper

function Mapper.new(bufnr)
  vim.validate({bufnr = {bufnr, "number"}})
  local tbl = {_bufnr = bufnr}
  return setmetatable(tbl, Mapper)
end

function Mapper.nowait_match(self, inputs)
  local buffer_gestures = gestures.buffer[self._bufnr]
  if buffer_gestures ~= nil then
    local gesture = filter_gesture_map(buffer_gestures, inputs, true)
    if gesture ~= nil then
      return gesture
    end
  end
  return filter_gesture_map(gestures.global, inputs, true)
end

function Mapper.match(self, inputs)
  local buffer_gestures = gestures.buffer[self._bufnr]
  if buffer_gestures ~= nil then
    local gesture = filter_gesture_map(buffer_gestures, inputs, false)
    if gesture ~= nil then
      return gesture
    end
  end
  return filter_gesture_map(gestures.global, inputs, false)
end

function Mapper.has_forward_match(self, inputs)
  local lhs = inputs:identify()
  local buffer_gestures = gestures.buffer[self._bufnr]
  if buffer_gestures ~= nil then
    for key in pairs(buffer_gestures) do
      if vim.startswith(key, lhs) then
        return true
      end
    end
  end

  for key in pairs(gestures.global) do
    if vim.startswith(key, lhs) then
      return true
    end
  end
  return false
end

return M
