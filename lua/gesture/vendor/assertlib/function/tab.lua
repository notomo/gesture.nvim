local M = {}

function M.tab_count()
  return vim.fn.tabpagenr("$")
end

function M.tab_number()
  return vim.fn.tabpagenr()
end

return M
