local Point = require("gesture.core.point")
local Canvas = require("gesture.view.canvas")
local windowlib = require("gesture.lib.window")
local mouse = require("gesture.view.mouse")
local hl_groups = require("gesture.view.highlight_group")

--- @class GestureBackground
--- @field get_position fun():{x:number,y:number}|nil
--- @field private _window_id integer
--- @field private _ns integer
local Background = {}
Background.__index = Background

function Background.open(winblend)
  local width = vim.o.columns
  local height = vim.o.lines

  local bufnr = vim.api.nvim_create_buf(false, true)
  local window_id = vim.api.nvim_open_win(bufnr, true, {
    width = width,
    height = height,
    relative = "editor",
    row = 0,
    col = 0,
    external = false,
    style = "minimal",
    zindex = 201,
  })
  vim.wo[window_id].winblend = winblend
  vim.wo[window_id].winhighlight = "Normal:" .. hl_groups.GestureBackground
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

  local get_position
  if vim.o.mousemoveevent then
    get_position = function()
      local mouse_pos = vim.fn.getmousepos()
      return Point.new(mouse_pos.screencol - 1, mouse_pos.screenrow)
    end
  else
    -- NOTE: show and move cursor to the window by <LeftDrag>
    vim.cmd.redraw()
    mouse.click()
    get_position = function()
      mouse.click()
      if not vim.api.nvim_win_is_valid(window_id) then
        return nil
      end
      local x = vim.fn.wincol()
      local y = vim.fn.winline()
      return Point.new(x, y)
    end
  end

  vim.api.nvim_create_autocmd({ "WinLeave", "TabLeave", "BufLeave" }, {
    buffer = bufnr,
    once = true,
    callback = function()
      require("gesture.command").cancel(window_id)
    end,
  })

  local ns = vim.api.nvim_create_namespace("gesture")
  local tbl = {
    get_position = get_position,
    _window_id = window_id,
    _ns = ns,
  }
  local self = setmetatable(tbl, Background)

  vim.api.nvim_set_decoration_provider(self._ns, {
    on_win = function(_, _, buf, topline)
      if topline == 0 or buf ~= bufnr or not self:_is_valid() then
        return false
      end
      vim.fn.winrestview({ topline = 0, leftcol = 0 })
    end,
  })

  return self, Canvas.new(bufnr, ns, width, height), window_id
end

function Background.close(self)
  windowlib.close(self._window_id)
  vim.api.nvim_set_decoration_provider(self._ns, {})
end

function Background._is_valid(self)
  return vim.api.nvim_win_is_valid(self._window_id)
end

return Background
