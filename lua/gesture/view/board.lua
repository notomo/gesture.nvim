local listlib = require("gesture/lib/list")
local vim = vim

local M = {}

local GestureBoard = {}
GestureBoard.__index = GestureBoard
M.GestureBoard = GestureBoard

local one_padding = 3
local both_padding = one_padding * 2
local round = function(x)
  return math.floor(x + 0.5)
end

function GestureBoard._new(range_map)
  local tbl = {range_map = range_map or {}}
  return setmetatable(tbl, GestureBoard)
end

function GestureBoard.create(inputs, gesture, has_forward_match)
  if inputs:is_empty() then
    return GestureBoard._new()
  end

  local editor_width = vim.o.columns
  local width = editor_width / 4

  local texts = listlib.wrap(inputs:values(), width - both_padding)
  local lines = {"", unpack(texts)}
  if gesture ~= nil then
    table.insert(lines, gesture.name)
  else
    table.insert(lines, "")
  end

  local row = math.max(2, math.floor(vim.o.lines / 2 - round(#lines / 2) - 1))
  local center = round(editor_width / 2)
  local half_width = round(width / 2)
  local start_col = math.max(0, center - half_width)
  local end_col = math.min(center + half_width, editor_width)

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

    local padding = math.floor((width - #line) / 2)
    local ranges = {
      {start_col, start_col + padding - 1, hl_group},
      {start_col + padding + #line, end_col, hl_group},
    }
    if gesture ~= nil and line == gesture.name then
      table.insert(ranges, 2, {
        start_col + padding,
        start_col + padding + #line,
        "GestureActionLabel",
        line,
      })
    elseif line ~= "" then
      table.insert(ranges, 2, {start_col + padding, start_col + padding + #line, hl_group, line})
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
