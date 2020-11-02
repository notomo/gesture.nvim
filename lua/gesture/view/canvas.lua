local M = {}

local Canvas = {}
Canvas.__index = Canvas
M.Canvas = Canvas

local vim = vim
local set_extmark = vim.api.nvim_buf_set_extmark
local ns = vim.api.nvim_create_namespace("gesture")

function Canvas.new(bufnr)
  local tbl = {_rows = {}, _bufnr = bufnr}
  return setmetatable(tbl, Canvas)
end

function Canvas.draw(self, board, points)
  for y, ranges in pairs(board.range_map) do
    self:_add_ranges(y, ranges)
  end

  local drawn = {}
  for _, p in ipairs(points) do
    self:_draw_point(p)
    drawn[p.y] = true
  end

  for y in pairs(board.range_map) do
    if not drawn[y] then
      self:_draw(y)
    end
  end
end

function Canvas._add_ranges(self, y, ranges)
  if #ranges == 0 then
    return
  end

  local row = self._rows[y] or {}
  local base_ranges = row.ranges or {}

  local first_x = ranges[1][1]
  local last_x = ranges[#ranges][2]

  local new_ranges = vim.tbl_filter(function(r)
    return r[3] ~= nil and r[3] == "GestureLine" and not (first_x <= r[1] and r[2] <= last_x)
  end, base_ranges)

  new_ranges = vim.tbl_map(function(r)
    if r[1] < first_x and first_x <= r[2] then
      return {r[1], first_x - 1, r[3]}
    end
    if r[1] <= last_x and last_x < r[2] then
      return {last_x + 1, r[2], r[3]}
    end
    return r
  end, new_ranges)

  local included = {}
  for i, r in ipairs(new_ranges) do
    if r[1] <= first_x and last_x <= r[2] then
      table.insert(included, i)
    end
  end
  for _, index in ipairs(included) do
    local r = new_ranges[index]
    table.insert(new_ranges, index + 1, {last_x + 1, r[2], r[3]})
    new_ranges[index] = {r[1], first_x - 1, r[3]}
  end

  for _, range in ipairs(ranges) do
    table.insert(new_ranges, range)
  end

  table.sort(new_ranges, function(a, b)
    return a[1] < b[1]
  end)

  self._rows[y] = {ranges = new_ranges, id = row.id}
end

function Canvas._draw(self, y)
  local row = self._rows[y] or {}
  local ranges = row.ranges or {}
  local virtual_texts = self._to_virtual_texts(ranges)
  local id = set_extmark(self._bufnr, ns, y - 1, 0, {virt_text = virtual_texts, id = row.id})
  self._rows[y] = {ranges = ranges, id = id}
end

function Canvas._draw_point(self, p)
  local row = self._rows[p.y] or {}
  local ranges = row.ranges or {}

  ranges = self:_add_point(ranges, p.x)
  ranges = self:_add_point(ranges, p.x - 1)

  local virtual_texts = self._to_virtual_texts(ranges)
  local id = set_extmark(self._bufnr, ns, p.y - 1, 0, {virt_text = virtual_texts, id = row.id})
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

function Canvas._to_virtual_texts(ranges)
  local virtual_texts = {}
  local col = 1
  for _, range in ipairs(ranges) do
    local s = range[1]
    local e = range[2]
    local before_space = s - col
    if before_space > 0 then
      local space = (" "):rep(before_space)
      table.insert(virtual_texts, {space})
    end
    local hl_group = range[3]
    local text = range[4]
    if text ~= nil then
      table.insert(virtual_texts, {text, hl_group})
    else
      local space = (" "):rep(e - s + 1)
      table.insert(virtual_texts, {space, hl_group})
    end
    col = e + 1
  end
  return virtual_texts
end

local highlights = require("gesture/lib/highlight")
highlights.default("GestureLine", {
  ctermbg = {"Statement", "fg", "cterm", 153},
  guibg = {"Statement", "fg", "gui", "#a8d2eb"},
  blend = 0,
})

return M
