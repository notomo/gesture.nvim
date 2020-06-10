local states = require "gesture/state"

local M = {}

local close_window = function(id)
  if id == "" then
    return
  end
  if not vim.api.nvim_win_is_valid(id) then
    return
  end
  vim.api.nvim_win_close(id, true)
end

local mouse = vim.api.nvim_eval('"\\<LeftMouse>"')

M.click = function()
  vim.api.nvim_command("normal! " .. mouse)
end

M.open = function()
  local state, ok = states.get_or_create()
  if ok then
    M.click()
    return state
  end

  local bufnr = vim.api.nvim_create_buf(false, true)

  local width = vim.o.columns
  local height = vim.o.lines

  local window_id =
    vim.api.nvim_open_win(
    bufnr,
    true,
    {
      width = width,
      height = height,
      relative = "editor",
      row = 0,
      col = 0,
      external = false,
      style = "minimal"
    }
  )
  vim.api.nvim_win_set_option(window_id, "winblend", 100)

  local line = (" "):rep(width)
  local lines = vim.fn["repeat"]({line}, height)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(bufnr, "filetype", "gesture")

  vim.api.nvim_win_set_option(window_id, "scrolloff", 0)
  vim.api.nvim_win_set_option(window_id, "sidescrolloff", 0)

  states.save(window_id, state)

  -- NOTE: show and move cursor to the window by <LeftDrag>
  vim.api.nvim_command("redraw")
  M.click()

  return state
end

M.close = function(state)
  if state == nil then
    return
  end
  close_window(0)
end

M.render = function(inputs)
  -- TODO
end

return M
