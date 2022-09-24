local M = {}

function M.window_count()
  return vim.fn.tabpagewinnr(vim.fn.tabpagenr(), "$")
end

function M.window_id()
  return vim.api.nvim_get_current_win()
end

return M
