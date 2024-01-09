local M = {}

--- Defines a default highlight group.
--- @param hl_group string: highlight group name
--- @param attributes table: |nvim_set_hl| val parameter
--- @return string # hl_group
function M.define(hl_group, attributes)
  local new_attributes = { default = true }
  for key, value in pairs(attributes) do
    new_attributes[key] = value
  end

  vim.api.nvim_set_hl(0, hl_group, new_attributes)

  return hl_group
end

--- Makes a highlight group link.
--- @param hl_group string: highlight group name
--- @param to string: highlight group name to link |:hl-link|
--- @return string # hl_group
function M.link(hl_group, to)
  vim.api.nvim_set_hl(0, hl_group, {
    link = to,
    default = true,
  })
  return hl_group
end

return M
