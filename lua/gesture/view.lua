local repository = require("gesture/repository")

local M = {}

M.open = function(virtualedit)
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

  vim.api.nvim_win_set_option(window_id, "scrolloff", 0)
  vim.api.nvim_win_set_option(window_id, "sidescrolloff", 0)
  vim.api.nvim_set_option("virtualedit", "all")

  -- NOTE: show and move cursor to the window by <LeftDrag>
  vim.api.nvim_command("redraw")

  local on_leave = ("autocmd WinLeave,TabLeave,BufLeave <buffer=%s> ++once lua require 'gesture/view'.close(%s, '%s')"):format(bufnr, window_id, virtualedit)
  vim.api.nvim_command(on_leave)

  return {id = window_id, bufnr = bufnr}
end

M.close = function(window_id, virtualedit)
  if window_id == "" then
    return
  end
  if not vim.api.nvim_win_is_valid(window_id) then
    return
  end
  vim.api.nvim_win_close(window_id, true)
  vim.o.virtualedit = virtualedit
  repository.delete(window_id)
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

  for _, view_range in ipairs(view_ranges) do
    table.insert(new_ranges, view_range)
  end

  table.sort(new_ranges, function(a, b)
    return a[1] < b[1]
  end)

  return new_ranges
end

M.render_input = function(bufnr, inputs, gesture, has_forward_match, new_points, mark_store)
  if #inputs == 0 then
    M._set_marks(bufnr, new_points, mark_store, {})
    return
  end

  local sep = " "
  local padding = 3
  local both_padding = padding * 2
  local width = vim.o.columns
  local view_width = width / 4

  local lines = {}
  for _, input in ipairs(inputs) do
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

  M._set_marks(bufnr, new_points, mark_store, view_ranges_map)
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

M._line_point = function(ranges, x)
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
    end
    if s <= x and x <= e then
      return nil
    end
  end
  local msg = ("bug: %s, %s"):format(vim.inspect(ranges), x)
  error(msg)
end

M._add_line_point = function(ranges, x)
  local new, index = M._line_point(ranges, x)
  if new ~= nil then
    table.insert(ranges, index, new)
  end
  return ranges
end

M._set_marks = function(bufnr, new_points, mark_store, view_ranges_map)
  local ns = vim.api.nvim_create_namespace("gesture")
  local ys = {}
  for _, p in ipairs(new_points) do
    local x = p[1]
    local y = p[2]
    table.insert(ys, y)
    local store = mark_store[y] or {}
    local ranges = M._add_line_point(view_ranges_map[y] or store.ranges or {}, x)
    local chunks = M._to_chunks(ranges)
    local id = vim.api.nvim_buf_set_extmark(bufnr, ns, y - 1, 0, {virt_text = chunks, id = store.id})
    mark_store[y] = {ranges = ranges, id = id}
  end
  for y, view_ranges in pairs(view_ranges_map) do
    if not vim.tbl_contains(ys, y) then
      local store = mark_store[y] or {}
      local chunks = M._to_chunks(view_ranges)
      local id = vim.api.nvim_buf_set_extmark(bufnr, ns, y - 1, 0, {
        virt_text = chunks,
        id = store.id,
      })
      mark_store[y] = {ranges = view_ranges, id = id}
    end
  end
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
