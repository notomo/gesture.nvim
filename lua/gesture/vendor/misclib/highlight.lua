local M = {}

function M.define(hl_group, attributes)
  local new_attributes = { default = true }
  for key, value in pairs(attributes) do
    new_attributes[key] = value
  end

  vim.api.nvim_set_hl(0, hl_group, new_attributes)

  return hl_group
end

function M.link(hl_group, to)
  vim.api.nvim_set_hl(0, hl_group, {
    link = to,
    default = true,
  })
  return hl_group
end

return M
