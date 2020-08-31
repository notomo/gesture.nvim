local M = {}

M.open = function()
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

  local line = (" "):rep(width)
  local lines = vim.fn["repeat"]({line}, height)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "filetype", "gesture")
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

  vim.api.nvim_win_set_option(window_id, "scrolloff", 0)
  vim.api.nvim_win_set_option(window_id, "sidescrolloff", 0)

  -- NOTE: show and move cursor to the window by <LeftDrag>
  vim.api.nvim_command("redraw")

  local on_win_leave = ("autocmd WinLeave <buffer=%s> ++once lua require 'gesture/view'.close(%s)"):format(bufnr, window_id)
  vim.api.nvim_command(on_win_leave)

  local on_tab_leave = ("autocmd TabLeave <buffer=%s> ++once lua require 'gesture/view'.close(%s)"):format(bufnr, window_id)
  vim.api.nvim_command(on_tab_leave)

  local on_buf_leave = ("autocmd BufLeave <buffer=%s> ++once lua require 'gesture/view'.close(%s)"):format(bufnr, window_id)
  vim.api.nvim_command(on_buf_leave)

  return {id = window_id, bufnr = bufnr}
end

M.close = function(window_id)
  if window_id == "" then
    return
  end
  if not vim.api.nvim_win_is_valid(window_id) then
    return
  end
  vim.api.nvim_win_close(window_id, true)
end

M.render_input = function(bufnr, inputs, gesture, has_forward_match)
  if #inputs == 0 then
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

  for i, line in ipairs(lines) do
    local remaining = (width - #line) / 2
    local space = (" "):rep(remaining)
    lines[i] = space .. line .. space
  end

  local row = math.floor(vim.o.lines / 2 - math.floor(#lines / 2 + 0.5) - 1)
  if row < 2 then
    row = 2
  end
  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(bufnr, row, row + #lines, false, lines)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

  local ns = vim.api.nvim_create_namespace("gesture")
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

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

  local highlight_group = "GestureInput"
  if not has_forward_match then
    highlight_group = "GestureNoAction"
  end
  for _, r in ipairs(vim.fn.range(row - 2, row + #lines)) do
    vim.api.nvim_buf_add_highlight(bufnr, ns, highlight_group, r, start_column, end_column)
  end
  vim.api.nvim_buf_add_highlight(bufnr, ns, "GestureActionLabel", row + #lines - 1, start_column, end_column)
end

return M
