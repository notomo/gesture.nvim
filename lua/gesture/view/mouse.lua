local M = {}

local mouse = vim.api.nvim_eval('"\\<LeftMouse>"')
-- replace on testing
function M.click()
  vim.cmd.normal({ bang = true, args = { mouse } })
end

return M
