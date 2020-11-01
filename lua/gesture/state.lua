local repository = require("gesture/repository")
local views = require("gesture/view")
local mappers = require("gesture/mapper")
local Point = require("gesture/point").Point
local Inputs = require("gesture/input").Inputs

local M = {}

local State = {}
State.__index = State

function State.update(self)
  M.click()

  if not self.view:is_valid() then
    return false
  end

  local point = Point.from_window()
  local last = self.view._new_points[#self.view._new_points] or self.last_point
  self.view._new_points = last:interpolate(point)

  local line = self.last_point:line_to(point)
  if line == nil or line:is_short() then
    return true
  end
  self.last_point = point

  local new_input = {kind = "direction", value = line.direction, length = line.length}
  self.inputs:add(new_input)

  return true
end

M.get_or_create = function()
  local current_state = M.get()
  if current_state ~= nil then
    return current_state
  end

  local mapper = mappers.new(vim.fn.bufnr("%"))
  local view = views.open()
  M.click()

  local tbl = {
    last_point = Point.from_window(),
    inputs = Inputs.new(),
    view = view,
    mapper = mapper,
  }
  local state = setmetatable(tbl, State)

  repository.set(state.view.window_id, state)

  return state
end

M.get = function()
  return repository.get(vim.api.nvim_get_current_win())
end

local mouse = vim.api.nvim_eval("\"\\<LeftMouse>\"")
-- replace on testing
M.click = function()
  vim.api.nvim_command("normal! " .. mouse)
end

return M
