local scenario = function(ctx)
  vim.o.termguicolors = true
  vim.o.background = "dark"
  require("gesture.view").click = function()
    vim.cmd("redraw!")
  end

  local gesture = require("gesture")
  gesture.register({
    name = "example name",
    inputs = {gesture.right(), gesture.down()},
    action = "normal! gg",
  })

  local width = vim.o.columns

  gesture.draw()
  ctx:screenshot()

  vim.cmd("normal! M")
  vim.cmd(("normal! %dl"):format(math.floor(width / 2)))
  gesture.draw()
  vim.cmd(("normal! %dl"):format(math.floor(width / 3)))
  gesture.draw()
  vim.cmd("normal! 10j")
  gesture.draw()
  ctx:screenshot()
  vim.cmd(("normal! %dh"):format(width))
  gesture.draw()
  ctx:screenshot()

  gesture.finish()
  ctx:screenshot()
end

local main = function(comparison, result_dir)
  vim.o.runtimepath = vim.fn.getcwd() .. "," .. vim.o.runtimepath
  vim.cmd("runtime! plugin/*.vim")

  local test = require("virtes").setup({scenario = scenario, result_dir = result_dir})
  local before = test:run({hash = comparison})
  before:write_replay_script()

  local after = test:run({hash = nil})
  after:write_replay_script()

  before:diff(after):write_replay_script()
end

return main
