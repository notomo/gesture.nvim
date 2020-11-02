local M = {}

local GestureBoard = {}
GestureBoard.__index = GestureBoard
M.GestureBoard = GestureBoard

local sep = " "
local padding = 3
local both_padding = padding * 2

function GestureBoard._new(range_map)
  local tbl = {range_map = range_map or {}}
  return setmetatable(tbl, GestureBoard)
end

function GestureBoard.create(inputs, gesture, has_forward_match)
  if inputs:is_empty() then
    return GestureBoard._new()
  end

  local width = vim.o.columns
  local view_width = width / 4

  local lines = {}
  for _, input in inputs:all() do
    local str = input.value
    local last = table.remove(lines, #lines)
    if last == nil then
      table.insert(lines, str)
    elseif #last + #sep + #str + both_padding > view_width then
      table.insert(lines, last)
      table.insert(lines, str)
    else
      table.insert(lines, last .. sep .. str)
    end
  end
  if gesture ~= nil then
    table.insert(lines, gesture.name)
  else
    table.insert(lines, "")
  end
  table.insert(lines, 1, "")

  local row = math.floor(vim.o.lines / 2 - math.floor(#lines / 2 + 0.5) - 1)
  if row < 2 then
    row = 2
  end

  local half_width = math.floor(width / 2 + 0.5)
  local half_view_width = math.floor(view_width / 2 + 0.5)
  local start_column = half_width - half_view_width
  local end_column = half_width + half_view_width
  if start_column < 0 then
    start_column = 0
  end
  if end_column > width then
    end_column = width
  end

  local hl_group = "GestureInput"
  if not has_forward_match then
    hl_group = "GestureNoAction"
  end

  local height = vim.api.nvim_win_get_height(0)
  local range_map = {}
  for i, line in ipairs(lines) do
    local y = row + i
    if y > height then
      break
    end

    local view_padding = math.floor((view_width - #line) / 2)

    local ranges = {
      {start_column, start_column + view_padding - 1, hl_group},
      {start_column + view_padding + #line, end_column, hl_group},
    }
    if gesture ~= nil and line == gesture.name then
      table.insert(ranges, 2, {
        start_column + view_padding,
        start_column + view_padding + #line,
        "GestureActionLabel",
        line,
      })
    elseif line ~= "" then
      table.insert(ranges, 2, {
        start_column + view_padding,
        start_column + view_padding + #line,
        hl_group,
        line,
      })
    end
    range_map[y] = ranges
  end

  return GestureBoard._new(range_map)
end

local highlights = require("gesture/lib/highlight")
local blend = 0
highlights.default("GestureInput", {
  ctermfg = {"NormalFloat", "fg", "cterm", 230},
  guifg = {"NormalFloat", "fg", "gui", "#fffeeb"},
  ctermbg = {"NormalFloat", "bg", "cterm", 235},
  guibg = {"NormalFloat", "bg", "gui", "#3a4b5c"},
  blend = blend,
  gui = "bold",
})
highlights.default("GestureNoAction", {
  ctermfg = {"Comment", "fg", "cterm", 103},
  guifg = {"Comment", "fg", "gui", "#8d9eb2"},
  ctermbg = {"NormalFloat", "bg", "cterm", 235},
  guibg = {"NormalFloat", "bg", "gui", "#3a4b5c"},
  blend = blend,
})
highlights.default("GestureActionLabel", {
  gui = "bold",
  ctermfg = {"Statement", "fg", "cterm", 153},
  guifg = {"Statement", "fg", "gui", "#a8d2eb"},
  blend = blend,
})

return M
