local M = {}

M.close = function(id)
  if not vim.api.nvim_win_is_valid(id) then
    return
  end
  vim.api.nvim_win_close(id, true)
end

M.by_pattern = function(pattern)
  local bufnr = vim.fn.bufnr(pattern)
  if bufnr == -1 then
    return nil
  end
  return vim.fn.win_findbuf(bufnr)[1]
end

return M
