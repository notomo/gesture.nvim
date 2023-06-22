local listlib = require("gesture.lib.list")
local vim = vim

local GestureBoard = {}
GestureBoard.__index = GestureBoard

local one_padding = 3
local both_padding = one_padding * 2

local round = function(x)
  return math.floor(x + 0.5)
end

local hl_groups = require("gesture.view.highlight_group")

function GestureBoard.create(inputs, gesture, can_match, show_board)
  if #inputs == 0 or not show_board then
    return {}
  end

  local editor_width = vim.o.columns
  local width = editor_width / 4

  local input_strs = require("gesture.core.inputs").strings(inputs)

  local texts = listlib.wrap(input_strs, width - both_padding)
  local lines = { "", unpack(texts) }
  if gesture then
    table.insert(lines, gesture.name)
  else
    table.insert(lines, "")
  end

  local row = math.max(2, math.floor(vim.o.lines / 2 - round(#lines / 2) - 1))
  local center = round(editor_width / 2)
  local half_width = round(width / 2)
  local start_col = math.max(0, center - half_width)
  local end_col = math.min(center + half_width, editor_width)

  local hl_group = hl_groups.GestureInput
  if not can_match then
    hl_group = hl_groups.GestureInputNotMatched
  end

  local height = vim.api.nvim_win_get_height(0)
  local range_map = {}
  local action_label_hl_group = hl_groups.GestureActionLabel
  for i, line in ipairs(lines) do
    local y = row + i
    if y > height then
      break
    end

    local padding = math.floor((width - #line) / 2)
    local ranges = {
      { start_col, start_col + padding, hl_group },
      { start_col + padding + #line + 1, end_col, hl_group },
    }

    local hl
    if gesture and line == gesture.name then
      hl = action_label_hl_group
    elseif line ~= "" then
      hl = hl_group
    end
    if hl then
      table.insert(ranges, 2, { start_col + padding + 1, start_col + padding + #line, hl, line })
    end

    range_map[y] = ranges
  end

  return range_map
end

return GestureBoard
