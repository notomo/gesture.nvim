local M = {}

M.root = require("gesture.lib.path").find_root()

function M.before_each()
  require("gesture.view").click = function()
  end
end

function M.after_each()
  vim.cmd("tabedit")
  vim.cmd("tabonly!")
  vim.cmd("silent! %bwipeout!")
  print(" ")

  vim.api.nvim_set_current_dir(M.root)

  require("gesture.lib.cleanup")()
end

function M.buffer_log()
  local lines = vim.fn.getbufline("%", 1, "$")
  for _, line in ipairs(lines) do
    print(line)
  end
end

function M.set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

function M.cursor()
  return {vim.fn.line("."), vim.fn.col(".")}
end

local vassert = require("vusted.assert")
local asserts = vassert.asserts
M.assert = vassert.assert

asserts.create("current_line"):register_eq(function()
  return vim.fn.getline(".")
end)

asserts.create("current_word"):register_eq(function()
  return vim.fn.expand("<cword>")
end)

asserts.create("window_count"):register_eq(function()
  return vim.fn.tabpagewinnr(vim.fn.tabpagenr(), "$")
end)

asserts.create("window_first_row"):register_eq(function()
  return vim.fn.line("w0")
end)

asserts.create("shown_in_view"):register(function(self)
  return function(_, args)
    local marks = vim.api.nvim_buf_get_extmarks(0, vim.api.nvim_create_namespace("gesture"), 0, -1, {
      details = true,
    })
    local lines = {}
    for _, mark in ipairs(marks) do
      local texts = vim.tbl_map(function(chunk)
        return chunk[1]
      end, mark[4].virt_text or {})
      local line = table.concat(texts, "")
      table.insert(lines, line)
    end
    local content = table.concat(lines, "\n")

    local pattern = args[1]
    local result = vim.fn.stridx(content, pattern)
    self:set_positive(("`%s` not found"):format(pattern))
    self:set_negative(("`%s` found"):format(pattern))
    return result ~= 0
  end
end)

return M
