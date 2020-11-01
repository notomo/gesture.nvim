local repository = require("gesture/repository")
local Point = require("gesture/point").Point

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
  if not vim.api.nvim_win_is_valid(self.window_id) then
    return
  end
  vim.api.nvim_win_close(self.window_id, true)
  vim.o.virtualedit = self._virtualedit
  repository.delete(self.window_id)
end

function View.render_input(self, inputs, gesture, has_forward_match)
  return M._render_input(self._bufnr, inputs, gesture, has_forward_match, self._new_points, self._mark_store)
end

function View.open()
  local bufnr = vim.api.nvim_create_buf(false, true)

  local width = vim.o.columns
  local height = vim.o.lines

  local window_id = vim.api.nvim_open_win(bufnr, true, {
    width = width,
    height = height,
    relative = "editor",
    row = 0,
    col = 0,
    external = false,
    style = "minimal",
  })
  vim.api.nvim_win_set_option(window_id, "winblend", 100)

  local lines = vim.fn["repeat"]({""}, height)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "filetype", "gesture")
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_buf_set_name(bufnr, "gesture://GESTURE")

  vim.api.nvim_win_set_option(window_id, "scrolloff", 0)
  vim.api.nvim_win_set_option(window_id, "sidescrolloff", 0)
  local virtualedit = vim.o.virtualedit
  vim.api.nvim_set_option("virtualedit", "all")

  -- NOTE: show and move cursor to the window by <LeftDrag>
  vim.api.nvim_command("redraw")
  M.click()

  local on_leave = ("autocmd WinLeave,TabLeave,BufLeave <buffer=%s> ++once lua require 'gesture/view'.close(%s)"):format(bufnr, window_id)
  vim.api.nvim_command(on_leave)

  local tbl = {
    window_id = window_id,
    _bufnr = bufnr,
    _virtualedit = virtualedit,
    _new_points = {},
    _mark_store = {},
  }
  return setmetatable(tbl, View)
end

M.close = function(window_id)
  local state = repository.get(window_id)
  if state == nil then
    return
  end
  state.view:close()
end

M._render_input = function(bufnr, inputs, gesture, has_forward_match, new_points, mark_store)
  if inputs:is_empty() then
    M._draw_view(bufnr, new_points, mark_store, {})
    return
  end

  local sep = " "
  local padding = 3
  local both_padding = padding * 2
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
  local view_ranges_map = {}
  for i, line in ipairs(lines) do
    local y = row + i
    if y > height then
      break
    end
    local store = mark_store[y] or {}

    local view_padding = math.floor((view_width - #line) / 2)

    local view_ranges = {
      {start_column, start_column + view_padding - 1, hl_group},
      {start_column + view_padding + #line, end_column, hl_group},
    }
    if gesture ~= nil and line == gesture.name then
      table.insert(view_ranges, 2, {
        start_column + view_padding,
        start_column + view_padding + #line,
        "GestureActionLabel",
        line,
      })
    elseif line ~= "" then
      table.insert(view_ranges, 2, {
        start_column + view_padding,
        start_column + view_padding + #line,
        hl_group,
        line,
      })
    end
    local new_ranges = M._add_view_ranges(store.ranges or {}, view_ranges)
    view_ranges_map[y] = new_ranges
  end

  M._draw_view(bufnr, new_points, mark_store, view_ranges_map)
end

M._add_view_ranges = function(ranges, view_ranges)
  if #view_ranges == 0 then
    return vim.deepcopy(ranges)
  end

  local first_x = view_ranges[1][1]
  local last_x = view_ranges[#view_ranges][2]

  local new_ranges = vim.tbl_filter(function(r)
    return r[3] ~= nil and r[3] == "GestureLine" and not (first_x <= r[1] and r[2] <= last_x)
  end, ranges)

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

  for _, view_range in ipairs(view_ranges) do
    table.insert(new_ranges, view_range)
  end

  table.sort(new_ranges, function(a, b)
    return a[1] < b[1]
  end)

  return new_ranges
end

M._to_chunks = function(ranges)
  local chunks = {}
  local col = 1
  for _, range in ipairs(ranges) do
    local s = range[1]
    local e = range[2]
    local before_space = s - col
    if before_space > 0 then
      local space = (" "):rep(before_space)
      table.insert(chunks, {space})
    end
    local hl_group = range[3]
    local text = range[4]
    if text ~= nil then
      table.insert(chunks, {text, hl_group})
    else
      local space = (" "):rep(e - s + 1)
      table.insert(chunks, {space, hl_group})
    end
    col = e + 1
  end
  return chunks
end

M._to_line_point = function(ranges, x)
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

M._add_line_point = function(ranges, x)
  local new, index = M._to_line_point(ranges, x)
  if new ~= nil then
    table.insert(ranges, index, new)
  end
  return ranges
end

local set_extmark = vim.api.nvim_buf_set_extmark
local ns = vim.api.nvim_create_namespace("gesture")

M._draw_view = function(bufnr, new_points, mark_store, view_ranges_map)
  local ys = {}
  for _, p in ipairs(new_points) do
    local x = p.x
    local y = p.y
    table.insert(ys, y)
    local store = mark_store[y] or {}

    local ranges = M._add_line_point(view_ranges_map[y] or store.ranges or {}, x)
    -- NOTE: for making the vertical line thicker
    ranges = M._add_line_point(ranges, x - 1)

    local chunks = M._to_chunks(ranges)
    local id = set_extmark(bufnr, ns, y - 1, 0, {virt_text = chunks, id = store.id})
    mark_store[y] = {ranges = ranges, id = id}
  end
  for y, view_ranges in pairs(view_ranges_map) do
    if not vim.tbl_contains(ys, y) then
      local store = mark_store[y] or {}
      local chunks = M._to_chunks(view_ranges)
      local id = set_extmark(bufnr, ns, y - 1, 0, {virt_text = chunks, id = store.id})
      mark_store[y] = {ranges = view_ranges, id = id}
    end
  end
end

local mouse = vim.api.nvim_eval("\"\\<LeftMouse>\"")
-- replace on testing
M.click = function()
  vim.api.nvim_command("normal! " .. mouse)
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
highlights.default("GestureLine", {
  ctermbg = {"Statement", "fg", "cterm", 153},
  guibg = {"Statement", "fg", "gui", "#a8d2eb"},
  blend = blend,
})

return M
