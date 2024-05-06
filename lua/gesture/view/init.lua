local Point = require("gesture.core.point")
local Background = require("gesture.view.background")
local GestureBoard = require("gesture.view.board")

--- @class GestureView
--- @field private _background GestureBackground
--- @field private _canvas GestureCanvas
--- @field private _new_points {x:number,y:number}[]
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
  local current_point = self._background.get_position()
  if not current_point then
    return nil
  end

  local last
  if last_point == nil then
    last = current_point
  else
    last = self._new_points[#self._new_points] or last_point
  end
  self._new_points = Point.interpolate(last, current_point)

  return current_point
end

function View.current_point(self)
  return self._background.get_position()
end

function View.close(self)
  self._background:close()
end

return View
