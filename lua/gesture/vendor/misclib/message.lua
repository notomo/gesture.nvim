local M = {}

local plugin_name = vim.split((...):gsub("%.", "/"), "/", { plain = true })[1]
local prefix = ("[%s] "):format(plugin_name)

function M.error(err)
  error(M.wrap(err), 0)
end

function M.warn(msg)
  vim.api.nvim_echo({ { M.wrap(msg), "WarningMsg" } }, true, {})
end

function M.user_error(msg)
  msg = M.wrap(msg)
  vim.api.nvim_echo({ { msg, "ErrorMsg" } }, true, {})
  vim.v.errmsg = msg
end

function M.info(msg, hl_group)
  vim.api.nvim_echo({ { M.wrap(msg), hl_group } }, true, {})
end

function M.wrap(msg)
  if type(msg) == "string" then
    return prefix .. msg
  end
  return prefix .. vim.inspect(msg)
end

return M
