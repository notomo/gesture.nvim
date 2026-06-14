local helper = require("ntf.helper")
local plugin_name = helper.get_module_root(...)

helper.root = helper.find_plugin_root(plugin_name)
vim.opt.packpath:prepend(vim.fs.joinpath(helper.root, "spec/.shared/packages"))
require("assertlib").register(require("ntf.assert").register)

function helper.before_each()
  ---@diagnostic disable-next-line: duplicate-set-field
  require("gesture.view.mouse").click = function() end
end

function helper.after_each()
  vim.api.nvim_set_current_dir(helper.root)
end

function helper.set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

local assert = require("ntf.assert")

assert.register_eq("window_first_row", function()
  return vim.fn.line("w0")
end)

assert.register("shown_in_view", function(self)
  return function(_, args)
    local marks = vim.api.nvim_buf_get_extmarks(0, vim.api.nvim_create_namespace("gesture"), 0, -1, {
      details = true,
    })
    local lines = {}
    for _, mark in ipairs(marks) do
      local texts = vim
        .iter(mark[4].virt_text or {})
        :map(function(chunk)
          return chunk[1]
        end)
        :totable()
      local line = table.concat(texts, "")
      table.insert(lines, line)
    end
    local content = table.concat(lines, "\n")

    local pattern = args[1]
    local result = vim.fn.stridx(content, pattern)
    self:set_positive(("`%s` not found"):format(pattern))
    self:set_negative(("`%s` found"):format(pattern))
    return result ~= -1
  end
end)

function helper.typed_assert(raw_assert)
  local x = require("assertlib").typed(raw_assert)
  ---@cast x +{shown_in_view:fun(want), window_first_row:fun(want)}
  ---@cast x +{no:{shown_in_view:fun(want), window_first_row:fun(want)}}
  return x
end

return helper
