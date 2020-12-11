local repository = require("gesture/lib/repository").Repository.new("state")
local View = require("gesture/view").View
local Matcher = require("gesture/model/matcher").Matcher
local Inputs = require("gesture/model/input").Inputs
local Input = require("gesture/model/input").Input

local M = {}

local State = {}
State.__index = State
M.State = State

function State.get_or_create()
  local current_state = State.get()
  if current_state ~= nil then
    return current_state
  end

  local matcher = Matcher.new(require("gesture").map, vim.api.nvim_get_current_buf())
  local view = View.open()
  local tbl = {
    _last_point = view.current_point(),
    inputs = Inputs.new(),
    view = view,
    matcher = matcher,
  }
  local state = setmetatable(tbl, State)

  repository:set(state.view.window_id, state)

  return state
end

function State.get(window_id)
  return repository:get(window_id or vim.api.nvim_get_current_win())
end

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
  self.inputs:add(Input.direction(line.direction, line.length))

  return true
end

function State.close(self)
  repository:delete(self.view.window_id)
  self.view:close()
end

return M
