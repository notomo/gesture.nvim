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

function View.render_input(self, inputs, gesture, has_forward_match)
  local board = GestureBoard.create(inputs, gesture, has_forward_match)
  self._background:draw(board, self._new_points)
end

function View.focus(self, last_point)
  M.click()

  if not self._background:is_valid() then
    return
  end

  local point = self.current_point()
  local last = self._new_points[#self._new_points] or last_point
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
  vim.cmd("normal! " .. mouse)
end

local highlightlib = require("gesture.lib.highlight")

local setup_highlight_groups = function()
  local blend = 0
  return {
    highlightlib.default("GestureLine", {
      ctermbg = { "Statement", 153 },
      guibg = { "Statement", "#a8d2eb" },
      blend = 25,
    }),
    highlightlib.default("GestureInput", {
      ctermfg = { "NormalFloat", 230 },
      guifg = { "NormalFloat", "#fffeeb" },
      ctermbg = { "NormalFloat", 235 },
      guibg = { "NormalFloat", "#3a4b5c" },
      blend = blend,
      gui = "bold",
    }),
    highlightlib.default("GestureInputNotMatched", {
      ctermfg = { "Comment", 103 },
      guifg = { "Comment", "#8d9eb2" },
      ctermbg = { "NormalFloat", 235 },
      guibg = { "NormalFloat", "#3a4b5c" },
      blend = blend,
    }),
    highlightlib.default("GestureActionLabel", {
      gui = "bold",
      ctermfg = { "Statement", 153 },
      guifg = { "Statement", "#a8d2eb" },
      blend = blend,
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
