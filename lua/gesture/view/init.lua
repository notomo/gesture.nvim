local Point = require("gesture.core.point")
local Background = require("gesture.view.background")
local GestureBoard = require("gesture.view.board")
local mouse = require("gesture.view.mouse")

local vim = vim

local View = {}
View.__index = View

function View.open(winblend)
  local background, canvas, window_id = Background.open(winblend)
  local tbl = {
    _background = background,
    _canvas = canvas,
    _new_points = {},
  }
  return setmetatable(tbl, View), window_id
end

function View.render_input(self, inputs, gesture, can_match, show_board)
  local board_range_map = GestureBoard.create(inputs, gesture, can_match, show_board)
  self._canvas:draw(board_range_map, self._new_points)
end

function View.focus(self, last_point)
  mouse.click()

  if not self._background:is_valid() then
    return
  end

  local current_point = self.current_point()

  local last
  if last_point == nil then
    last = current_point
  else
    last = self._new_points[#self._new_points] or last_point
  end
  self._new_points = Point.interpolate(last, current_point)

  return current_point
end

function View.current_point()
  local x = vim.fn.wincol()
  local y = vim.fn.winline()
  return Point.new(x, y)
end

function View.close(self)
  self._background:close()
end

return View
