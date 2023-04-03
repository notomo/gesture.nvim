local setup_highlight_groups = function()
  local highlightlib = require("gesture.vendor.misclib.highlight")
  local blend = 0
  return {
    GestureLine = highlightlib.define("GestureLine", {
      bg = vim.api.nvim_get_hl(0, { name = "Statement" }).fg or "#a8d2eb",
      blend = 25,
    }),
    GestureInput = highlightlib.define("GestureInput", {
      fg = vim.api.nvim_get_hl(0, { name = "NormalFloat" }).fg or "#fffeeb",
      bg = vim.api.nvim_get_hl(0, { name = "NormalFloat" }).bg or "#3a4b5c",
      blend = blend,
      bold = true,
    }),
    GestureInputNotMatched = highlightlib.define("GestureInputNotMatched", {
      fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg or "#8d9eb2",
      bg = vim.api.nvim_get_hl(0, { name = "NormalFloat" }).bg or "#3a4b5c",
      blend = blend,
    }),
    GestureActionLabel = highlightlib.define("GestureActionLabel", {
      fg = vim.api.nvim_get_hl(0, { name = "Statement" }).fg or "#a8d2eb",
      blend = blend,
      bold = true,
    }),
  }
end

local group = vim.api.nvim_create_augroup("gesture", {})
vim.api.nvim_create_autocmd({ "ColorScheme" }, {
  group = group,
  pattern = { "*" },
  callback = setup_highlight_groups,
})

return setup_highlight_groups()
