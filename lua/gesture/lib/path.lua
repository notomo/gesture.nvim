local M = {}

M.find_root = function(root_dir_name)
  local suffix = "/lua/%?.lua"
  local target = ("%s%s$"):format(root_dir_name, suffix)
  for _, path in ipairs(vim.split(package.path, ";")) do
    if M.adjust_sep(path):find(target) then
      return path:sub(1, #path - #suffix + 1), nil
    end
  end
  return nil, "project root directory not found"
end

if vim.fn.has("win32") == 1 then
  M.adjust_sep = function(path)
    return path:gsub("\\", "/")
  end
else
  M.adjust_sep = function(path)
    return path
  end
end

return M
