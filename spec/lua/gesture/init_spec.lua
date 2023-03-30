local helper = require("gesture.test.helper")
local gesture = helper.require("gesture")

describe("gesture.register()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can register a global gesture", function()
    gesture.register({ inputs = { gesture.down(), gesture.up() }, action = "normal! gg" })

    helper.set_lines([[
hoge


foo]])
    vim.cmd.normal({ args = { "G" }, bang = true })

    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10k" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.current_line("hoge")
  end)

  it("can register a buffer local gesture", function()
    gesture.register({
      inputs = { gesture.right(), gesture.left() },
      action = "normal! $",
      buffer = "%",
    })
    gesture.register({ inputs = { gesture.right(), gesture.left() }, action = "normal! 0" })

    helper.set_lines([[
hoge         foo
]])

    gesture.draw()
    vim.cmd.normal({ args = { "10l" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10h" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.cursor_word("foo")
  end)

  it("can use function as action", function()
    gesture.register({
      inputs = { gesture.down(), gesture.up() },
      action = function()
        vim.cmd.normal({ args = { "gg" }, bang = true })
      end,
    })

    helper.set_lines([[
hoge


foo]])
    vim.cmd.normal({ args = { "G" }, bang = true })

    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10k" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.current_line("hoge")
  end)

  it("can use callable as action", function()
    local called = false
    local action = setmetatable({}, {
      __call = function()
        called = true
      end,
    })

    gesture.register({ inputs = { gesture.down(), gesture.up() }, action = action })

    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10k" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.is_true(called)
  end)

  it("can use action context", function()
    local ctx
    gesture.register({
      inputs = { gesture.right(), gesture.down() },
      action = function(param)
        ctx = param
      end,
      nowait = true,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "20l" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()

    assert.equals(ctx.last_position[1], 11)
    assert.equals(ctx.last_position[2], 21)
  end)

  it("can register a global and buffer local gesture", function()
    gesture.register({
      inputs = { gesture.right({ min_length = 10 }) },
      action = "normal! $",
      buffer = "%",
    })
    gesture.register({ inputs = { gesture.right() }, action = "normal! G" })

    helper.set_lines([[
hoge         foo
bar]])

    gesture.draw()
    vim.cmd.normal({ args = { "8l" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.cursor_word("bar")
  end)

  it("can register a nowait buffer local gesture", function()
    gesture.register({ inputs = { gesture.right() }, action = "normal! $", nowait = true, buffer = "%" })
    gesture.register({ inputs = { gesture.right() }, action = "normal! 0", nowait = true })
    gesture.register({
      inputs = { gesture.right(), gesture.left() },
      action = "normal! 0",
      buffer = "%",
    })

    helper.set_lines([[
hoge         foo
]])

    gesture.draw()
    vim.cmd.normal({ args = { "10l" }, bang = true })
    gesture.draw()

    assert.window_count(1)
    assert.cursor_word("foo")
  end)

  it("can register a gesture with max length", function()
    gesture.register({ inputs = { gesture.right({ max_length = 10 }) }, action = "normal! $" })

    helper.set_lines([[
hoge         foo
]])

    gesture.draw()
    vim.cmd.normal({ args = { "11l" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.cursor_word("hoge")
  end)

  it("can register a gesture with min length", function()
    gesture.register({ inputs = { gesture.right({ min_length = 10 }) }, action = "normal! $" })

    helper.set_lines([[
hoge         foo
]])

    gesture.draw()
    vim.cmd.normal({ args = { "9l" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.cursor_word("hoge")
  end)

  it("overwrites the same gesture", function()
    gesture.register({ inputs = { gesture.right(), gesture.left() }, action = "normal! w" })
    gesture.register({ inputs = { gesture.right(), gesture.left() }, action = "normal! 2w" })

    helper.set_lines([[hoge foo bar]])

    gesture.draw()
    vim.cmd.normal({ args = { "10l" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10h" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.cursor_word("bar")
  end)

  it("does not overwrite gesture has the different attribute", function()
    gesture.register({
      inputs = { gesture.right({ max_length = 20 }), gesture.left() },
      action = "normal! w",
    })
    gesture.register({
      inputs = { gesture.right({ min_length = 20 }), gesture.left() },
      action = "normal! 2w",
    })

    helper.set_lines([[hoge foo bar]])

    gesture.draw()
    vim.cmd.normal({ args = { "10l" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10h" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.cursor_word("foo")
  end)
end)

describe("gesture.draw()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("shows input gestures", function()
    gesture.draw()
    vim.cmd.normal({ args = { "10l" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10h" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10k" }, bang = true })
    gesture.draw()

    assert.shown_in_view("RIGHT")
    assert.shown_in_view("DOWN")
    assert.shown_in_view("LEFT")
    assert.shown_in_view("UP")
  end)

  it("shows matched gesture name", function()
    gesture.register({ name = "to bottom", inputs = { gesture.down() }, action = "normal! G" })
    gesture.register({
      name = "to top",
      inputs = { gesture.down(), gesture.up() },
      action = "normal! gg",
    })

    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()

    assert.shown_in_view("DOWN")
    assert.shown_in_view("to bottom")

    vim.cmd.normal({ args = { "10k" }, bang = true })
    gesture.draw()

    assert.shown_in_view("UP")
    assert.shown_in_view("to top")
  end)

  it("executes a nowait gesture if it is matched", function()
    gesture.register({ inputs = { gesture.right() }, action = "normal! $", nowait = true })

    helper.set_lines([[
hoge         foo
]])

    gesture.draw()
    vim.cmd.normal({ args = { "10l" }, bang = true })
    gesture.draw()

    assert.window_count(1)
    assert.cursor_word("foo")
  end)

  it("resets scroll on scrolled", function()
    gesture.draw()
    vim.cmd.normal({ args = { "G" }, bang = true })
    vim.cmd.normal({ args = { "zz" }, bang = true })

    -- NOTE: zz may not fire callback in headless mode.
    vim.cmd.redraw()

    assert.window_first_row(1)
  end)

  it("raises no error with many gestures", function()
    for _ = 0, 100, 1 do
      gesture.draw()
      vim.cmd.normal({ args = { "10j" }, bang = true })
      gesture.draw()
      vim.cmd.normal({ args = { "10k" }, bang = true })
    end
    assert.shown_in_view("UP")
  end)

  it("does not create multiple gesture state", function()
    vim.cmd.tabedit()
    gesture.draw()
    vim.cmd.tabprevious({ mods = { noautocmd = true } })

    gesture.draw()
    vim.cmd.tabnext()

    assert.window_count(1)
  end)

  it("can disable board", function()
    gesture.draw({ show_board = false })
    vim.cmd.normal({ args = { "10l" }, bang = true })

    assert.no.shown_in_view("RIGHT")
  end)
end)

describe("gesture.finish()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("does nothing for non matched gesture", function()
    gesture.register({ inputs = { gesture.down(), gesture.up() }, action = "normal! G" })

    helper.set_lines([[
hoge


foo]])

    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.current_line("hoge")
  end)

  it("raises error if action raises error", function()
    gesture.register({ inputs = { gesture.down() }, action = "invalid_command" })

    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()

    local ok, err = pcall(function()
      gesture.finish()
    end)
    assert.is_false(ok)
    assert.match("Vim:E492: Not an editor command: invalid_command", err)
  end)
end)

describe("gesture.cancel()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can cancel gesture", function()
    gesture.register({ inputs = { gesture.down(), gesture.up() }, action = "normal! gg" })

    helper.set_lines([[
hoge


foo]])
    vim.cmd.normal({ args = { "G" }, bang = true })

    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10k" }, bang = true })
    gesture.draw()
    gesture.cancel()

    assert.window_count(1)
    assert.current_line("foo")
  end)
end)

describe("gesture.clear()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can clear gestures", function()
    gesture.register({ inputs = { gesture.down(), gesture.up() }, action = "normal! gg" })
    gesture.clear()

    helper.set_lines([[
hoge


foo]])
    vim.cmd.normal({ args = { "G" }, bang = true })

    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10k" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.current_line("foo")
  end)
end)
