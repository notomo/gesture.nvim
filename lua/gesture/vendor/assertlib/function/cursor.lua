local M = {}

function M.cursor_row()
  return vim.fn.line(".")
end

function M.cursor_column()
  return vim.fn.col(".")
end

function M.cursor_position()
  return vim.api.nvim_win_get_cursor(0)
end

function M.cursor_word()
  return vim.fn.expand("<cword>")
end

return M
