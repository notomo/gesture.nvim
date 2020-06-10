local gestures = require "gesture"

local M = {}

local filter_gesture = function(gesture, inputs, nowait)
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

local filter_action = function(gesture_map, inputs, nowait)
  local lhss = {}
  for _, input in ipairs(inputs) do
    table.insert(lhss, input.value)
  end
  local lhs = table.concat(lhss, "-")

  local gs = gesture_map[lhs]
  if gs == nil then
    return nil
  end

  for _, gesture in ipairs(gs) do
    local g = filter_gesture(gesture, inputs, nowait)
    if g ~= nil then
      return g.action
    end
  end

  return nil
end

M.no_wait_action = function(bufnr, inputs)
  local buffer_gestures = gestures.buffer[bufnr]
  if buffer_gestures ~= nil then
    local action = filter_action(buffer_gestures, inputs, true)
    if action ~= nil then
      return action
    end
  end
  return filter_action(gestures.global, inputs, true)
end

M.action = function(bufnr, inputs)
  local buffer_gestures = gestures.buffer[bufnr]
  if buffer_gestures ~= nil then
    local action = filter_action(buffer_gestures, inputs, false)
    if action ~= nil then
      return action
    end
  end
  return filter_action(gestures.global, inputs, false)
end

return M
