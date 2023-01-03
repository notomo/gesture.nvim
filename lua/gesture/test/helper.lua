local helper = require("vusted.helper")
local plugin_name = helper.get_module_root(...)

helper.root = helper.find_plugin_root(plugin_name)

function helper.before_each()
  require("gesture.view").click = function() end
end

function helper.after_each()
  vim.api.nvim_set_current_dir(helper.root)
  helper.cleanup()
  helper.cleanup_loaded_modules(plugin_name)
  print(" ")
end

function helper.set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

local asserts = require("vusted.assert").asserts
local asserters = require(plugin_name .. ".vendor.assertlib").list()
require(plugin_name .. ".vendor.misclib.test.assert").register(asserts.create, asserters)

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

return helper
