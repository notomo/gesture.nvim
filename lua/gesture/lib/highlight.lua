local M = {}

local attrs = {
  ctermfg = {"fg", "cterm"},
  guifg = {"fg", "gui"},
  ctermbg = {"bg", "cterm"},
  guibg = {"bg", "gui"},
}
function M.default(name, attributes)
  local attr = ""
  for key, v in pairs(attributes) do
    local value
    if type(v) == "table" then
      local hl_group, default = unpack(v)
      local attr_key, mode = unpack(attrs[key])
      local id = vim.api.nvim_get_hl_id_by_name(hl_group)
      local attr_value = vim.fn.synIDattr(id, attr_key, mode)
      if attr_value ~= "" then
        value = attr_value
      else
        value = default
      end
    else
      value = v
    end
    attr = attr .. (" %s=%s"):format(key, value)
  end

  local cmd = ("highlight default %s %s"):format(name, attr)
  vim.cmd(cmd)
  return name
end

return M
