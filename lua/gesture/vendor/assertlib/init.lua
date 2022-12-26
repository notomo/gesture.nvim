local M = {}

local dir_parts = vim.split((...):gsub("/", "."), ".", { plain = true })
function M.list()
  local base_index = vim.fn.index(dir_parts, "assertlib")
  local base_parts = vim.list_slice(dir_parts, 1, base_index + 1)
  local base_path = table.concat(base_parts, "/")

  local function_pattern = ("lua/%s/function/*.lua"):format(base_path)
  local module_paths = vim.api.nvim_get_runtime_file(function_pattern, true)
  local module_names = vim.tbl_map(function(path)
    path = path:gsub("\\", "/")
    local splitted = vim.split(path, "/", { plain = true })
    local file_name = splitted[#splitted]
    local name = file_name:sub(1, #file_name - 4)
    return name
  end, module_paths)

  local all = {}
  local base_module_path = table.concat(base_parts, ".")
  for _, module_name in ipairs(module_names) do
    local module = require(base_module_path .. ".function." .. module_name)
    local asserters = require(base_module_path .. ".asserter").from(module)
    vim.list_extend(all, asserters)
  end

  table.sort(all, function(a, b)
    return a.name > b.name
  end)

  return all
end

return M
