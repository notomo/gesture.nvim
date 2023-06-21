local _states = {}

local Inputs = require("gesture.core.inputs")

local State = {}
State.__index = State

function State.get_or_create(open_view)
  local current = State.get()
  if current then
    return current
  end

  local first_window_id = vim.api.nvim_get_current_win()
  local matcher = require("gesture.core.matcher").new(vim.api.nvim_get_current_buf())
  local view, window_id = open_view()
  local tbl = {
    _last_point = view.current_point(),
    _window_id = window_id,
    _first_window_id = first_window_id,
    _suspended = false,
    _inputs = {},
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

function State.update(self, length_thresholds)
  local point = self.view:focus(self._last_point)
  if not point then
    return false
  end

  if self._last_point == nil then
    self._last_point = point
  end

  local line = self._last_point:line_to(point)
  if not line or line:is_short(length_thresholds) then
    return true
  end

  self._last_point = point
  Inputs.add_direction(self._inputs, line.direction, line.length, self._suspended)
  self._suspended = false

  return true
end

function State.suspend(self)
  self._last_point = nil
  self._suspended = true
end

function State.close(self)
  _states[self._window_id] = nil
  self.view:close()
end

function State.action_context(self)
  local point = self.view.current_point()
  local last_position = { point.y, point.x }
  return {
    inputs = vim.tbl_map(function(input)
      return input
    end, self._inputs),
    last_position = last_position,
    window_id = self._first_window_id,
    last_window_id = function()
      return require("gesture.lib.window").from_global_position(0, last_position)
    end,
  }
end

return State
