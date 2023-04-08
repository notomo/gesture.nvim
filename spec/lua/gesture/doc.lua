local util = require("genvdoc.util")
local plugin_name = vim.env.PLUGIN_NAME
local full_plugin_name = plugin_name .. ".nvim"

local example_path = ("./spec/lua/%s/example.lua"):format(plugin_name)
dofile(example_path)

require("genvdoc").generate(full_plugin_name, {
  chapters = {
    {
      name = function(group)
        return "Lua module: " .. group
      end,
      group = function(node)
        if node.declaration == nil or node.declaration.type ~= "function" then
          return nil
        end
        return node.declaration.module
      end,
    },
    {
      name = "STRUCTURE",
      group = function(node)
        if node.declaration == nil or node.declaration.type ~= "class" then
          return nil
        end
        return "STRUCTURE"
      end,
    },
    {
      name = "HIGHLIGHT GROUPS",
      body = function(ctx)
        local descriptions = {
          GestureLine = [[
used for drawing gesture line
]],
          GestureInput = [[
used for input
]],
          GestureInputNotMatched = [[
used for input if no matched gesture exists 
]],
          GestureActionLabel = [[
used for action label
]],
          GestureBackground = [[
used for background window
]],
        }
        local sections = {}
        local hl_groups = vim.tbl_keys(require("gesture.view.highlight_group"))
        table.sort(hl_groups, function(a, b)
          return a > b
        end)
        for _, hl_group in ipairs(hl_groups) do
          table.insert(
            sections,
            util.help_tagged(ctx, hl_group, "hl-" .. hl_group) .. util.indent(descriptions[hl_group], 2)
          )
        end
        return vim.trim(table.concat(sections, "\n"))
      end,
    },
    {
      name = "EXAMPLE",
      body = function()
        return util.help_code_block_from_file(example_path, { language = "lua" })
      end,
    },
  },
})

local gen_readme = function()
  local f = io.open(example_path, "r")
  local usage = f:read("*a")
  f:close()

  local content = ([[
# gesture.nvim

[![ci](https://github.com/notomo/gesture.nvim/workflows/ci/badge.svg?branch=master)](https://github.com/notomo/gesture.nvim/actions/workflows/ci.yml?query=branch%%3Amaster)

gesture.nvim is a mouse gesture plugin for Neovim (nightly).

<img src="https://raw.github.com/wiki/notomo/gesture.nvim/images/gesture.gif">

## Example

```lua
%s```
]]):format(usage)

  local readme = io.open("README.md", "w")
  readme:write(content)
  readme:close()
end
gen_readme()
