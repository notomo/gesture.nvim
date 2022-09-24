local M = {}

function M.mode()
  return vim.api.nvim_get_mode().mode
end

return M
