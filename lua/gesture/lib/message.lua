local M = {}

local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local prefix = ("[%s] "):format(plugin_name)

function M.error(err)
  error(prefix .. err)
end

function M.warn(msg)
  vim.api.nvim_echo({{prefix .. msg, "WarningMsg"}}, true, {})
end

return M
