local M = {}

M.execute = function(action)
  return vim.fn.execute(action)
end

return M
