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
        if not node.declaration then
          return nil
        end
        return node.declaration.module
      end,
    },
    {
      name = "PARAMETERS",
      body = function(ctx)
        return util.help_tagged(ctx, "Gesture info", "gesture.nvim-gesture-info")
          .. [[

- {name} (string | nil): a displayed name
- {inputs} (table): inputs definition
- {action} (string | callable(ctx)): an action executed on matched.
    callable can use |gesture.nvim-action-context| as an argument.
- {nowait} (boolean | nil): to define nowait gesture
- {buffer} (string | number | nil): to define the buffer local gesture

]]
          .. util.help_tagged(ctx, "Action context", "gesture.nvim-action-context")
          .. [[

- {ctx} (table): gesture context
  - {last_position} (table): tha last position drawn by gesture

]]
          .. util.help_tagged(ctx, "Input options", "gesture.nvim-input-opts")
          .. [[

- {max_length} (number | nil) max length of the input line
- {min_length} (number | nil) min length of the input line]]
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
        }
        local sections = {}
        for _, hl_group in ipairs(require("gesture.view").hl_groups) do
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
        return util.help_code_block_from_file(example_path)
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

<img src="https://raw.github.com/wiki/notomo/gesture.nvim/images/gesture.gif" width="1280">

## Example

```lua
%s```
]]):format(usage)

  local readme = io.open("README.md", "w")
  readme:write(content)
  readme:close()
end
gen_readme()
