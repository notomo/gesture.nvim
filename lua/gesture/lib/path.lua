local M = {}

local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]

function M.find_root()
  local root_pattern = ("lua/%s/*.lua"):format(plugin_name)
  local file = vim.api.nvim_get_runtime_file(root_pattern, false)[1]
  if file == nil then
    error("project root directory not found by pattern: " .. root_pattern)
  end
  return vim.split(M.adjust_sep(file), "/lua/", true)[1]
end

if vim.fn.has("win32") == 1 then
  function M.adjust_sep(path)
    return path:gsub("\\", "/")
  end
else
  function M.adjust_sep(path)
    return path
  end
end

return M
