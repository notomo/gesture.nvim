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

local POINT_PRIORITY = 1000
local BOARD_PRIORITY = POINT_PRIORITY + 1
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

function Canvas._draw_point(self, p)
  local row = self._rows[p.y] or {}
  local col_map = row.col_map or {}

  if p.x >= 0 then
    col_map[p.x] = true
  end
  if p.x > 0 then
    col_map[p.x - 1] = true
  end

  local cols = vim.tbl_keys(col_map)
  table.sort(cols, function(a, b)
    return a < b
  end)

  local virtual_texts = converter.to_virtual_texts(cols, "GestureLine")
  local id = set_extmark(self._bufnr, ns, p.y - 1, 0, {
    virt_text = virtual_texts,
    virt_text_pos = "overlay",
    id = row.id,
    priority = POINT_PRIORITY,
  })
  self._rows[p.y] = {col_map = col_map, id = id}
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
