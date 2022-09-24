local M = {}

function M.current_line()
  return vim.api.nvim_get_current_line()
end

function M.filetype()
  return vim.bo.filetype
end

function M.buffer_name()
  return vim.api.nvim_buf_get_name(0)
end

function M.buffer_number()
  return vim.api.nvim_get_current_buf()
end

M.exists_pattern = {
  get_expected = function(pattern)
    return pattern:gsub("\n", "\\n")
  end,
  is_ok = function(result)
    return vim.fn.search(result.expected, "n") ~= 0
  end,
  positive_message = function(result)
    return ("`%s` not found"):format(result.expected)
  end,
  negative_message = function(result)
    return ("`%s` found"):format(result.expected)
  end,
}

return M
