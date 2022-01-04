local M = {}

local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local prefix = ("[%s] "):format(plugin_name)

function M.error(err)
  vim.validate({ err = { err, "string" } })
  error(prefix .. err)
end

function M.user_error(err)
  local msg = prefix .. tostring(err)
  vim.api.nvim_echo({ { msg, "ErrorMsg" } }, true, {})
  vim.v.errmsg = msg
end

return M
