local scenario = function(ctx)
  vim.o.termguicolors = true
  vim.o.background = "dark"
  require("gesture.view.mouse").click = function()
    vim.cmd.redraw({ bang = true })
  end

  local gesture = require("gesture")
  gesture.register({
    name = "example name",
    inputs = { gesture.right(), gesture.down() },
    action = "normal! gg",
  })

  local width = vim.o.columns

  gesture.draw()
  ctx:screenshot()

  vim.cmd.normal({ args = { "M" }, bang = true })
  vim.cmd.normal({ args = { ("%dl"):format(math.floor(width / 2)) }, bang = true })
  gesture.draw()
  vim.cmd.normal({ args = { ("%dl"):format(math.floor(width / 3)) }, bang = true })
  gesture.draw()
  vim.cmd.normal({ args = { "10j" }, bang = true })
  gesture.draw()
  ctx:screenshot()
  vim.cmd.normal({ args = { ("%dh"):format(width) }, bang = true })
  gesture.draw()
  ctx:screenshot()

  gesture.finish()
  ctx:screenshot()
end

local main = function(comparison, result_dir)
  local deploy_lua_dir = vim.fn.trim(vim.fn.system("luarocks --lua-version=5.1 config deploy_lua_dir"))
  package.path = package.path .. ";" .. deploy_lua_dir .. "/?.lua;" .. deploy_lua_dir .. "/?/init.lua"
  vim.o.runtimepath = vim.fn.getcwd() .. "," .. vim.o.runtimepath
  vim.cmd.runtime({ args = { "plugin/*.vim" }, bang = true })

  local test = require("virtes").setup({ scenario = scenario, result_dir = result_dir })
  local before = test:run({ hash = comparison })
  before:write_replay_script()

  local after = test:run({ hash = nil })
  after:write_replay_script()

  before:diff(after):write_replay_script()
end

return main
