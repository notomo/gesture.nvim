local converter = require("gesture.view.converter")

local M = {}

local Canvas = {}
Canvas.__index = Canvas
M.Canvas = Canvas

local vim = vim
local set_extmark = vim.api.nvim_buf_set_extmark
local ns = vim.api.nvim_create_namespace("gesture")

function Canvas.new(bufnr)
  local tbl = {_rows = {}, _board_rows = {}, _bufnr = bufnr}
  return setmetatable(tbl, Canvas)
end

function Canvas.draw(self, board, points)
  for y, ranges in pairs(board.range_map) do
    self:_draw_board(y, ranges)
  end
  for _, p in ipairs(points) do
    self:_draw_point(p)
  end
end

local BOARD_PRIORITY = 1001
function Canvas._draw_board(self, y, ranges)
  local row = self._board_rows[y] or {}
  local col, virtual_texts = converter.board_to_virtual_texts(ranges)
  local id = set_extmark(self._bufnr, ns, y - 1, col, {
    virt_text = virtual_texts,
    virt_text_pos = "overlay",
    id = row.id,
    priority = BOARD_PRIORITY,
  })
  self._board_rows[y] = {id = id}
end

local POINT_PRIORITY = 1000
function Canvas._draw_point(self, p)
  local row = self._rows[p.y] or {}
  local ranges = row.ranges or {}

  ranges = self:_add_point(ranges, p.x)
  ranges = self:_add_point(ranges, p.x - 1)

  local virtual_texts = converter.to_virtual_texts(ranges)
  local id = set_extmark(self._bufnr, ns, p.y - 1, 0, {
    virt_text = virtual_texts,
    virt_text_pos = "overlay",
    id = row.id,
    priority = POINT_PRIORITY,
  })
  self._rows[p.y] = {ranges = ranges, id = id}
end

function Canvas._to_line_point(ranges, x)
  if x == 0 then
    return nil
  end
  local p = {x, x, "GestureLine"}

  local last = ranges[#ranges]
  if last == nil then
    return p, 1
  elseif last[2] < x then
    return p, #ranges + 1
  end

  for i, range in ipairs(ranges) do
    local s = range[1]
    local e = range[2]

    if x < s then
      return p, i
    elseif s <= x and x <= e then
      return nil
    end
  end
  local msg = ("bug: %s, %s"):format(vim.inspect(ranges), x)
  error(msg)
end

function Canvas._add_point(self, ranges, x)
  local new, index = self._to_line_point(ranges, x)
  if new ~= nil then
    table.insert(ranges, index, new)
  end
  return ranges
end

local highlights = require("gesture.lib.highlight")
M.hl_groups = {
  highlights.default("GestureLine", {
    ctermbg = {"Statement", 153},
    guibg = {"Statement", "#a8d2eb"},
    blend = 25,
  }),
}

return M
