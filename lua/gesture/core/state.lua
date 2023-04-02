local Matcher = require("gesture.core.matcher")
local Inputs = require("gesture.core.input").Inputs
local Input = require("gesture.core.input").Input

local _states = {}

local State = {}
State.__index = State

function State.get_or_create(open_view)
  local current = State.get()
  if current then
    return current
  end

  local matcher = Matcher.new(require("gesture.core.setting").map, vim.api.nvim_get_current_buf())
  local view, window_id = open_view()
  local tbl = {
    _last_point = view.current_point(),
    _window_id = window_id,
    inputs = Inputs.new(),
    view = view,
    matcher = matcher,
  }
  local self = setmetatable(tbl, State)

  _states[self._window_id] = self

  return self
end

function State.get(window_id)
  return _states[window_id or vim.api.nvim_get_current_win()]
end

function State.update(self)
  local suspended = self._last_point == nil
  local point = self.view:focus(self._last_point)
  if not point then
    return false
  end

  if suspended then
    self._last_point = point
  end

  local line = self._last_point:line_to(point)
  if not line or line:is_short() then
    return true
  end

  self._last_point = point
  self.inputs:add(Input.direction(line.direction, line.length))

  return true
end

function State.suspend(self)
  self._last_point = nil
  self.inputs:suspend()
end

function State.close(self)
  local param = self:_action_param()

  _states[self._window_id] = nil
  self.view:close()

  return param
end

function State._action_param(self)
  local point = self.view.current_point()
  return { last_position = { point.y, point.x } }
end

return State
