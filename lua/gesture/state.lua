local View = require("gesture.view").View
local Matcher = require("gesture.model.matcher")
local Inputs = require("gesture.model.input").Inputs
local Input = require("gesture.model.input").Input

local _states = {}

local State = {}
State.__index = State

function State.get_or_create()
  local current = State.get()
  if current then
    return current
  end

  local matcher = Matcher.new(require("gesture.model.setting").map, vim.api.nvim_get_current_buf())
  local view = View.open()
  local tbl = {
    _last_point = view.current_point(),
    inputs = Inputs.new(),
    view = view,
    matcher = matcher,
  }
  local self = setmetatable(tbl, State)

  _states[self.view.window_id] = self

  return self
end

function State.get(window_id)
  return _states[window_id or vim.api.nvim_get_current_win()]
end

function State.update(self)
  local point = self.view:focus(self._last_point)
  if not point then
    return false
  end

  local line = self._last_point:line_to(point)
  if not line or line:is_short() then
    return true
  end

  self._last_point = point
  self.inputs:add(Input.direction(line.direction, line.length))

  return true
end

function State.close(self)
  local param = self:_action_param()

  _states[self.view.window_id] = nil
  self.view:close()

  return param
end

function State._action_param(self)
  local point = self.view.current_point()
  return { last_position = { point.y, point.x } }
end

return State
