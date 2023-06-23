local helper = require("gesture.test.helper")
local gesture = helper.require("gesture")

describe("gesture.register()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can register a global gesture with inputs", function()
    local called = false
    gesture.register({
      inputs = { gesture.down(), gesture.up() },
      action = function()
        called = true
      end,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10k" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.is_true(called)
  end)

  it("can register a buffer local gesture with inputs", function()
    local called = false
    gesture.register({
      inputs = { gesture.right(), gesture.left() },
      action = function()
        called = true
      end,
      buffer = "%",
    })
    gesture.register({
      inputs = { gesture.right(), gesture.left() },
      action = "normal! 0",
    })

    gesture.draw()
    vim.cmd.normal({ args = { "10l" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10h" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.is_true(called)
  end)

  it("can register a global gesture with match", function()
    local called = false
    gesture.register({
      match = function(ctx)
        local last_input = ctx.inputs[#ctx.inputs]
        return last_input and last_input.direction == "DOWN"
      end,
      action = function()
        called = true
      end,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "10l" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.is_true(called)
  end)

  it("can register a buffer local gesture with match", function()
    local called = false
    gesture.register({
      match = function(ctx)
        local input1 = ctx.inputs[1]
        local input2 = ctx.inputs[2]
        return input1 and input2 and input1.direction == "RIGHT" and input2.direction == "LEFT"
      end,
      action = function()
        called = true
      end,
      buffer = "%",
    })
    gesture.register({
      match = function(ctx)
        local input1 = ctx.inputs[1]
        local input2 = ctx.inputs[2]
        return input1 and input2 and input1.direction == "RIGHT" and input2.direction == "LEFT"
      end,
      action = function()
        error("should not be called")
      end,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "10l" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10h" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.is_true(called)
  end)

  it("can register a nowait gesture with inputs", function()
    local called = false
    gesture.register({
      inputs = { gesture.right() },
      action = function()
        called = true
      end,
      nowait = true,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "10l" }, bang = true })
    gesture.draw()

    assert.window_count(1)
    assert.is_true(called)
  end)

  it("can register a nowait gesture with match", function()
    local called = false
    gesture.register({
      match = function(ctx)
        local input1 = ctx.inputs[1]
        local input2 = ctx.inputs[2]
        return input1 and input2 and input1.direction == "RIGHT" and input2.direction == "LEFT"
      end,
      action = function()
        called = true
      end,
      nowait = true,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "10l" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10h" }, bang = true })
    gesture.draw()

    assert.window_count(1)
    assert.is_true(called)
  end)

  it("can register a gesture with match, can_match", function()
    local called = false
    gesture.register({
      match = function(ctx)
        local input2 = ctx.inputs[2]
        return input2 and input2.direction == "LEFT"
      end,
      can_match = function(ctx)
        local input1 = ctx.inputs[1]
        return input1 and input1.direction == "RIGHT"
      end,
      action = function()
        called = true
      end,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "10l" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10h" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.is_true(called)
  end)

  it("can use string command as action", function()
    gesture.register({
      inputs = { gesture.down(), gesture.up() },
      action = "normal! gg",
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

    assert.current_line("hoge")
  end)

  it("can use function as action", function()
    local called = false
    gesture.register({
      inputs = { gesture.down(), gesture.up() },
      action = function()
        called = true
      end,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10k" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.is_true(called)
  end)

  it("can use callable as action", function()
    local called = false
    local action = setmetatable({}, {
      __call = function()
        called = true
      end,
    })

    gesture.register({
      inputs = { gesture.down(), gesture.up() },
      action = action,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10k" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.is_true(called)
  end)

  it("can use action context last_position", function()
    local got
    gesture.register({
      inputs = { gesture.right(), gesture.down() },
      action = function(ctx)
        got = ctx
      end,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "20l" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.is_same(got.last_position, { 11, 21 })
  end)

  it("can use action context inputs", function()
    local got
    gesture.register({
      inputs = { gesture.right(), gesture.down() },
      action = function(ctx)
        got = ctx
      end,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "20l" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.is_same(got.inputs, {
      {
        direction = "RIGHT",
        length = 20,
      },
      {
        direction = "DOWN",
        length = 10,
      },
    })
  end)

  it("can use action context window_ids", function()
    local got
    gesture.register({
      inputs = { gesture.right(), gesture.down() },
      action = function(ctx)
        got = ctx
      end,
    })

    local window_id1 = vim.api.nvim_get_current_win()
    vim.cmd.vsplit()
    vim.cmd.split()
    local window_id3 = vim.api.nvim_get_current_win()

    local floating_window_id = vim.api.nvim_open_win(0, false, {
      width = 10,
      height = 10,
      relative = "editor",
      row = 0,
      col = 20,
      focusable = true,
      external = false,
      style = "minimal",
    })

    gesture.draw()
    vim.cmd.normal({ args = { "25l" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "55l" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.is_same(got.window_ids, { window_id3, floating_window_id, window_id1 })
  end)

  it("can register a global and buffer local gesture", function()
    gesture.register({
      inputs = { gesture.right({ min_length = 10 }) },
      action = function()
        error("should not be called")
      end,
      buffer = "%",
    })
    local called = false
    gesture.register({
      inputs = { gesture.right() },
      action = function()
        called = true
      end,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "8l" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.is_true(called)
  end)

  it("can register a nowait buffer local gesture", function()
    local called = false
    gesture.register({
      inputs = { gesture.right() },
      action = function()
        called = true
      end,
      nowait = true,
      buffer = "%",
    })
    gesture.register({
      inputs = { gesture.right() },
      action = function()
        error("should not be called")
      end,
      nowait = true,
    })
    gesture.register({
      inputs = { gesture.right(), gesture.left() },
      action = function()
        error("should not be called")
      end,
      buffer = "%",
    })

    gesture.draw()
    vim.cmd.normal({ args = { "10l" }, bang = true })
    gesture.draw()

    assert.is_true(called)
  end)

  it("can register a gesture with max length", function()
    local called = false
    gesture.register({
      inputs = { gesture.right({ max_length = 10 }) },
      action = function()
        called = true
      end,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "11l" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.is_false(called)
  end)

  it("can register a gesture with min length", function()
    local called = false
    gesture.register({
      inputs = { gesture.right({ min_length = 10 }) },
      action = function()
        called = true
      end,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "9l" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.is_false(called)
  end)

  it("overwrites the same gesture", function()
    gesture.register({
      inputs = { gesture.right(), gesture.left() },
      action = function()
        error("should not be called")
      end,
    })
    local called = false
    gesture.register({
      inputs = { gesture.right(), gesture.left() },
      action = function()
        called = true
      end,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "10l" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10h" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.is_true(called)
  end)

  it("does not overwrite gesture has the different attribute", function()
    local called = false
    gesture.register({
      inputs = { gesture.right({ max_length = 20 }), gesture.left() },
      action = function()
        called = true
      end,
    })
    gesture.register({
      inputs = { gesture.right({ min_length = 20 }), gesture.left() },
      action = function()
        error("should not be called")
      end,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "10l" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10h" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.is_true(called)
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
    gesture.register({
      name = "to bottom",
      inputs = { gesture.down() },
      action = "normal! G",
    })
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
    local called = false
    gesture.register({
      inputs = { gesture.down(), gesture.up() },
      action = function()
        called = true
      end,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.window_count(1)
    assert.is_false(called)
  end)

  it("raises error if action raises error", function()
    gesture.register({
      inputs = { gesture.down() },
      action = "invalid_command",
    })

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
    local called = false
    gesture.register({
      inputs = { gesture.down(), gesture.up() },
      action = function()
        called = true
      end,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10k" }, bang = true })
    gesture.draw()
    gesture.cancel()

    assert.window_count(1)
    assert.is_false(called)
  end)
end)

describe("gesture.suspend()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can suspend gesture", function()
    local called = false
    gesture.register({
      inputs = { gesture.down(), gesture.down() },
      action = function()
        called = true
      end,
    })

    gesture.draw()
    vim.cmd.normal({ args = { "5j" }, bang = true })

    gesture.draw()
    gesture.suspend()

    gesture.draw()
    vim.cmd.normal({ args = { "5j" }, bang = true })

    gesture.draw()
    assert.shown_in_view("DOWN DOWN")

    gesture.finish()

    assert.window_count(1)
    assert.is_true(called)
  end)
end)

describe("gesture.clear()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can clear gestures", function()
    local called = false
    gesture.register({
      inputs = { gesture.down(), gesture.up() },
      action = function()
        called = true
      end,
    })
    gesture.clear()

    gesture.draw()
    vim.cmd.normal({ args = { "10j" }, bang = true })
    gesture.draw()
    vim.cmd.normal({ args = { "10k" }, bang = true })
    gesture.draw()
    gesture.finish()

    assert.is_false(called)
  end)
end)
