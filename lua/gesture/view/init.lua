local Point = require("gesture.model.point")
local Background = require("gesture.view.background")
local GestureBoard = require("gesture.view.board").GestureBoard

local vim = vim

local M = {}

local View = {}
View.__index = View
M.View = View

function View.open()
  local background, window_id = Background.open(M.click)
  local tbl = { window_id = window_id, _background = background, _new_points = {} }
  return setmetatable(tbl, View)
end

function View.render_input(self, inputs, gesture, has_forward_match, show_board)
  local board = GestureBoard.create(inputs, gesture, has_forward_match, show_board)
  self._background:draw(board, self._new_points)
end

function View.focus(self, last_point)
  M.click()

  if not self._background:is_valid() then
    return
  end

  if not last_point then
    self._new_points = {}
  end

  local point = self.current_point()
  local last = self._new_points[#self._new_points] or last_point or point
  self._new_points = last:interpolate(point)

  return point
end

function View.current_point()
  local x = vim.fn.wincol()
  local y = vim.fn.winline()
  return Point.new(x, y)
end

function View.close(self)
  self._background:close()
end

local mouse = vim.api.nvim_eval('"\\<LeftMouse>"')
-- replace on testing
function M.click()
  vim.cmd.normal({ bang = true, args = { mouse } })
end

local setup_highlight_groups = function()
  local highlightlib = require("gesture.vendor.misclib.highlight")
  local blend = 0
  return {
    highlightlib.define("GestureLine", {
      bg = vim.api.nvim_get_hl(0, { name = "Statement" }).fg or "#a8d2eb",
      blend = 25,
    }),
    highlightlib.define("GestureInput", {
      fg = vim.api.nvim_get_hl(0, { name = "NormalFloat" }).fg or "#fffeeb",
      bg = vim.api.nvim_get_hl(0, { name = "NormalFloat" }).bg or "#3a4b5c",
      blend = blend,
      bold = true,
    }),
    highlightlib.define("GestureInputNotMatched", {
      fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg or "#8d9eb2",
      bg = vim.api.nvim_get_hl(0, { name = "NormalFloat" }).bg or "#3a4b5c",
      blend = blend,
    }),
    highlightlib.define("GestureActionLabel", {
      fg = vim.api.nvim_get_hl(0, { name = "Statement" }).fg or "#a8d2eb",
      blend = blend,
      bold = true,
    }),
  }
end

local group = vim.api.nvim_create_augroup("gesture", {})
vim.api.nvim_create_autocmd({ "ColorScheme" }, {
  group = group,
  pattern = { "*" },
  callback = setup_highlight_groups,
})

M.hl_groups = setup_highlight_groups()

return M
