local repository = require("gesture/lib/repository")
local View = require("gesture/view").View
local Matcher = require("gesture/matcher").Matcher
local Inputs = require("gesture/model/input").Inputs

local M = {}

local State = {}
State.__index = State

function State.update(self)
  local point = self.view:focus(self._last_point)
  if point == nil then
    return false
  end

  local line = self._last_point:line_to(point)
  if line == nil or line:is_short() then
    return true
  end
  self._last_point = point

  local new_input = {kind = "direction", value = line.direction, length = line.length}
  self.inputs:add(new_input)

  return true
end

M.get_or_create = function()
  local current_state = M.get()
  if current_state ~= nil then
    return current_state
  end

  local matcher = Matcher.new(vim.api.nvim_get_current_buf())
  local view = View.open()
  local tbl = {
    _last_point = view.current_point(),
    inputs = Inputs.new(),
    view = view,
    matcher = matcher,
  }
  local state = setmetatable(tbl, State)

  repository.set(state.view.window_id, state)

  return state
end

M.get = function()
  return repository.get(vim.api.nvim_get_current_win())
end

return M
