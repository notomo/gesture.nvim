local M = {}

function M.current_line()
  return vim.api.nvim_get_current_line()
end

function M.filetype()
  return vim.bo.filetype
end

function M.buffer_full_name()
  return vim.api.nvim_buf_get_name(0)
end

function M.buffer_name_tail()
  local full_name = vim.api.nvim_buf_get_name(0)
  return vim.fn.fnamemodify(full_name, ":t")
end

function M.buffer_number()
  return vim.api.nvim_get_current_buf()
end

M.exists_pattern = {
  get_expected_args = function(args)
    return args
  end,
  get_expected = function(pattern)
    return pattern:gsub("\n", "\\n")
  end,
  is_ok = function(result)
    local bufnr = result.expected_args[2] or 0
    return vim.api.nvim_buf_call(bufnr, function()
      return vim.fn.search(result.expected, "n") ~= 0
    end)
  end,
  positive_message = function(result)
    local bufnr = result.expected_args[2] or 0
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local content = table.concat(lines, "\n")
    return ([[`%s` not found
Actual lines:
%s]]):format(result.expected, content)
  end,
  negative_message = function(result)
    local bufnr = result.expected_args[2] or 0
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local content = table.concat(lines, "\n")
    return ([[`%s` found
Actual lines:
%s]]):format(result.expected, content)
  end,
}

return M
