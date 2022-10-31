local M = {}

local tail_messages = function(messages)
  local limit = 100
  local length = #messages
  local tail = table.concat(vim.list_slice(messages, length - limit, length), "\n")
  return tail, limit
end

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
    local actual, limit = tail_messages(result.actual)
    return ([[`%s` not found message
Actual messages tail (max: %d):
%s]]):format(result.expected, limit, actual)
  end,
  negative_message = function(result)
    local actual, limit = tail_messages(result.actual)
    return ([[`%s` found message
Actual messages tail (max: %d):
%s]]):format(result.expected, limit, actual)
  end,
}

return M
