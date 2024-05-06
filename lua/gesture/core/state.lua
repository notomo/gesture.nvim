--- @type table<integer,GestureState>
local _states = {}

local Inputs = require("gesture.core.inputs")
local DirectionInput = require("gesture.core.direction_input")
local windowlib = require("gesture.lib.window")

--- @class GestureState
--- @field private _suspended boolean
--- @field private _last_point {x:number,y:number}|nil
--- @field matcher GestureMatcher
--- @field view GestureView
local State = {}
State.__index = State

--- @param open_view fun():GestureView,integer
function State.get_or_create(open_view)
  local current = State.get()
  if current then
    return current
  end

  local first_window_id = vim.api.nvim_get_current_win()
  local matcher = require("gesture.core.matcher").new(vim.api.nvim_get_current_buf())
  local view, window_id = open_view()
  local point = view:current_point()
  local tbl = {
    _last_point = point,
    _suspended = false,
    _inputs = {},
    _window_id = window_id,

    _window_ids = { first_window_id },

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

  local window_id = windowlib.from_global_position(0, { point.y, point.x }, function(window_id)
    return window_id ~= self._window_id
  end)
  local last_window_id = self._window_ids[#self._window_ids]
  if window_id ~= last_window_id then
    table.insert(self._window_ids, window_id)
  end

  local input = DirectionInput.from_points(self._last_point, point)
  if not input or DirectionInput.is_short(input, length_thresholds) then
    return true
  end

  self._last_point = point
  Inputs.add_direction(self._inputs, input, self._suspended)
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
  local point = self.view:current_point()
  return {
    last_position = {
      point.y,
      point.x,
    },

    inputs = vim
      .iter(self._inputs)
      :map(function(input)
        return input
      end)
      :totable(),

    window_ids = vim
      .iter(self._window_ids)
      :map(function(window_id)
        return window_id
      end)
      :totable(),
  }
end

return State
