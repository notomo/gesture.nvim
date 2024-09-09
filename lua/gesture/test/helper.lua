local helper = require("vusted.helper")
local plugin_name = helper.get_module_root(...)

helper.root = helper.find_plugin_root(plugin_name)
vim.opt.packpath:prepend(vim.fs.joinpath(helper.root, "spec/.shared/packages"))
require("assertlib").register(require("vusted.assert").register)

function helper.before_each()
  ---@diagnostic disable-next-line: duplicate-set-field
  require("gesture.view.mouse").click = function() end
end

function helper.after_each()
  vim.api.nvim_set_current_dir(helper.root)
  helper.cleanup()
  helper.cleanup_loaded_modules(plugin_name)
end

function helper.set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

local asserts = require("vusted.assert").asserts

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

function helper.typed_assert(assert)
  local x = require("assertlib").typed(assert)
  ---@cast x +{shown_in_view:fun(want), window_first_row:fun(want)}
  ---@cast x +{no:{shown_in_view:fun(want), window_first_row:fun(want)}}
  return x
end

return helper
