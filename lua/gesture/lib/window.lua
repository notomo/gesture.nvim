local M = {}

function M.close(id)
  if not vim.api.nvim_win_is_valid(id) then
    return
  end
  vim.api.nvim_win_close(id, true)
end

function M.by_pattern(pattern)
  local bufnr = vim.fn.bufnr(pattern)
  if bufnr == -1 then
    return nil
  end
  return vim.fn.win_findbuf(bufnr)[1]
end

return M
