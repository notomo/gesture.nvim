local Canvas = require("gesture.view.canvas")
local windowlib = require("gesture.lib.window")

local Background = {}
Background.__index = Background

function Background.open(click)
  vim.validate({ click = { click, "function" } })

  local width = vim.o.columns
  local height = vim.o.lines - vim.o.cmdheight

  local bufnr = vim.api.nvim_create_buf(false, true)
  local window_id = vim.api.nvim_open_win(bufnr, true, {
    width = width,
    height = height,
    relative = "editor",
    row = 0,
    col = 0,
    external = false,
    style = "minimal",
  })
  vim.wo[window_id].winblend = 100
  vim.wo[window_id].scrolloff = 0
  vim.wo[window_id].sidescrolloff = 0

  local lines = vim.fn["repeat"]({ (" "):rep(width) }, height)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].filetype = "gesture"
  vim.bo[bufnr].modifiable = false

  local before_window_id = windowlib.by_pattern("^gesture://")
  if before_window_id then
    require("gesture.command").cancel(before_window_id)
  end
  vim.api.nvim_buf_set_name(bufnr, ("gesture://%d/GESTURE"):format(bufnr))

  -- NOTE: show and move cursor to the window by <LeftDrag>
  vim.cmd.redraw()
  click()

  vim.api.nvim_create_autocmd({ "WinLeave", "TabLeave", "BufLeave" }, {
    buffer = bufnr,
    once = true,
    callback = function()
      require("gesture.command").cancel(window_id)
    end,
  })

  local ns = vim.api.nvim_create_namespace("gesture")
  local tbl = {
    _window_id = window_id,
    _ns = ns,
  }
  local self = setmetatable(tbl, Background)

  vim.api.nvim_set_decoration_provider(self._ns, {
    on_win = function(_, _, buf, topline)
      if topline == 0 or buf ~= bufnr or not self:is_valid() then
        return false
      end
      vim.fn.winrestview({ topline = 0, leftcol = 0 })
    end,
  })

  return self, Canvas.new(bufnr, ns), window_id
end

function Background.close(self)
  windowlib.close(self._window_id)
  vim.api.nvim_set_decoration_provider(self._ns, {})
end

function Background.is_valid(self)
  return vim.api.nvim_win_is_valid(self._window_id)
end

return Background
