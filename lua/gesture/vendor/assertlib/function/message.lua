local M = {}

M.exists_message = {
  get_actual = function()
    return vim.split(vim.api.nvim_exec("messages", true), "\n")
  end,
  is_ok = function(result)
    for _, msg in ipairs(result.actual) do
      if msg:match(result.expected) then
        return true
      end
    end
    return false
  end,
  positive_message = function(result)
    return ("`%s` not found message"):format(result.expected)
  end,
  negative_message = function(result)
    return ("`%s` found message"):format(result.expected)
  end,
}

return M
