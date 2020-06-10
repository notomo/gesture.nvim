local M = {}

M.root = vim.fn.getcwd()

M.command = function(cmd)
  vim.api.nvim_command(cmd)
end

M.before_each = function()
  require("gesture/view").click = function()
  end
end

M.after_each = function()
  M.command("tabedit")
  M.command("tabonly!")
  M.command("silent! %bwipeout!")
  print(" ")

  -- NOTE: for require("test.helper")
  vim.api.nvim_set_current_dir(M.root)

  require("gesture/cleanup")("gesture")
end

M.buffer_log = function()
  local lines = vim.fn.getbufline("%", 1, "$")
  for _, line in ipairs(lines) do
    print(line)
  end
end

M.set_lines = function(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

M.cursor = function()
  return {vim.fn.line("."), vim.fn.col(".")}
end

local assert = require("luassert")
local AM = {}

AM.current_line = function(expected)
  local actual = vim.fn.getline(".")
  local msg = ("current line should be %s, but actual: %s"):format(expected, actual)
  assert.equals(expected, actual, msg)
end

AM.window_count = function(expected)
  local actual = vim.fn.tabpagewinnr(vim.fn.tabpagenr(), "$")
  local msg = ("window count should be %s, but actual: %s"):format(expected, actual)
  assert.equals(expected, actual, msg)
end

M.assert = AM

return M
