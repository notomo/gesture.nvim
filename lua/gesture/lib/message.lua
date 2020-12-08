local M = {}

M.error = function(err)
  vim.api.nvim_err_write("[gesture] " .. err .. "\n")
end

return M
