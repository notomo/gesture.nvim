local scenario = function(ctx)
  vim.o.termguicolors = true
  vim.o.background = "dark"
  require("gesture/view").click = function()
  end

  local gesture = require("gesture")
  gesture.register({
    name = "example name",
    inputs = {gesture.right(), gesture.down()},
    action = "normal! gg",
  })

  local width = vim.o.columns

  vim.api.nvim_command("Gesture draw")
  ctx:screenshot()

  vim.api.nvim_command("normal! M")
  vim.api.nvim_command(("normal! %dl"):format(math.floor(width / 2)))
  vim.api.nvim_command("Gesture draw")
  vim.api.nvim_command(("normal! %dl"):format(math.floor(width / 3)))
  vim.api.nvim_command("Gesture draw")
  vim.api.nvim_command("normal! 10j")
  vim.api.nvim_command("Gesture draw")
  ctx:screenshot()
  vim.api.nvim_command(("normal! %dh"):format(width))
  vim.api.nvim_command("Gesture draw")
  ctx:screenshot()

  vim.api.nvim_command("Gesture finish")
  ctx:screenshot()
end

local main = function(compare_hash, result_path)
  vim.o.runtimepath = vim.fn.getcwd() .. "," .. vim.o.runtimepath
  vim.api.nvim_command("runtime! plugin/*.vim")

  local test = require("gesture/lib/testlib/screenshot").setup({
    scenario = scenario,
    quit_on_err = true,
    result_path = result_path,
    cleanup = function()
      vim.api.nvim_command("tabedit")
      vim.api.nvim_command("tabonly!")
      vim.api.nvim_command("silent! %bwipeout!")
      require("gesture/lib/cleanup")()
    end,
  })
  local before = test:run({hash = compare_hash})
  local after = test:run({hash = nil})

  test:diff(before, after)
end

return main
