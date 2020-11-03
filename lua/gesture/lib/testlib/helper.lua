local M = {}

local root, err = require("gesture/lib/path").find_root("gesture/*.lua")
if err ~= nil then
  error(err)
end
M.root = root

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

  vim.api.nvim_set_current_dir(M.root)

  require("gesture/lib/cleanup")()
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
