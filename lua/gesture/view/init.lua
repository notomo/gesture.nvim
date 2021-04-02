local windowlib = require("gesture.lib.window")
local Point = require("gesture.model.point").Point
local Canvas = require("gesture.view.canvas").Canvas
local GestureBoard = require("gesture.view.board").GestureBoard

local vim = vim

local M = {}

local View = {}
View.__index = View
M.View = View

function View.current_point()
  local x = vim.fn.wincol()
  local y = vim.fn.winline()
  return Point.new(x, y)
end

function View.focus(self, last_point)
  M.click()

  if not vim.api.nvim_win_is_valid(self.window_id) then
    return
  end

  local point = self.current_point()
  local last = self._new_points[#self._new_points] or last_point
  self._new_points = last:interpolate(point)

  return point
end

function View.close(self)
  vim.o.virtualedit = self._virtualedit
  windowlib.close(self.window_id)
  vim.api.nvim_set_decoration_provider(vim.api.nvim_create_namespace("gesture"), {})
end

function View.open()
  local bufnr = vim.api.nvim_create_buf(false, true)

  local width = vim.o.columns
  local height = vim.o.lines - vim.o.cmdheight

  local window_id = vim.api.nvim_open_win(bufnr, true, {
    width = width,
    height = height,
    relative = "editor",
    row = 0,
    col = 0,
    external = false,
    style = "minimal",
  })
  vim.wo[window_id].winblend = 100

  local lines = vim.fn["repeat"]({""}, height)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].filetype = "gesture"
  vim.bo[bufnr].modifiable = false

  local before_window_id = windowlib.by_pattern("^gesture://")
  if before_window_id ~= nil then
    require("gesture.command").Command.cancel(before_window_id)
  end
  vim.api.nvim_buf_set_name(bufnr, ("gesture://%d/GESTURE"):format(bufnr))

  vim.wo[window_id].scrolloff = 0
  vim.wo[window_id].sidescrolloff = 0

  local virtualedit = vim.o.virtualedit
  vim.o.virtualedit = "all"

  -- NOTE: show and move cursor to the window by <LeftDrag>
  vim.cmd("redraw")
  M.click()

  local on_leave = ("autocmd WinLeave,TabLeave,BufLeave <buffer=%s> ++once lua require('gesture.command').Command.cancel(%s)"):format(bufnr, window_id)
  vim.cmd(on_leave)

  local tbl = {
    window_id = window_id,
    _virtualedit = virtualedit,
    _canvas = Canvas.new(bufnr),
    _new_points = {},
  }
  local view = setmetatable(tbl, View)

  vim.api.nvim_set_decoration_provider(vim.api.nvim_create_namespace("gesture"), {
    on_win = function(_, _, buf, topline)
      if topline == 0 or buf ~= bufnr or not vim.api.nvim_win_is_valid(window_id) then
        return false
      end
      vim.fn.winrestview({topline = 0, leftcol = 0})
    end,
  })

  return view
end

function View.render_input(self, inputs, gesture, has_forward_match)
  local board = GestureBoard.create(inputs, gesture, has_forward_match)
  self._canvas:draw(board, self._new_points)
end

local mouse = vim.api.nvim_eval("\"\\<LeftMouse>\"")
-- replace on testing
function M.click()
  vim.cmd("normal! " .. mouse)
end

return M
