local helper = require("gesture/lib/testlib/helper")
local command = helper.command

describe("gesture.nvim", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can register and execute a global gesture", function()
    local gesture = require("gesture")
    gesture.register({inputs = {gesture.down(), gesture.up()}, action = "normal! gg"})

    helper.set_lines([[
hoge


foo]])
    command("normal! G")

    command("Gesture draw")
    command("normal! 10j")
    command("Gesture draw")
    command("normal! 10k")
    command("Gesture draw")
    command("Gesture finish")

    assert.window_count(1)
    assert.current_line("hoge")
  end)

  it("can register and execute a buffer local gesture", function()
    local gesture = require("gesture")
    gesture.register({
      inputs = {gesture.right(), gesture.left()},
      action = "normal! $",
      buffer = "%",
    })
    gesture.register({inputs = {gesture.right(), gesture.left()}, action = "normal! 0"})

    helper.set_lines([[
hoge         foo
]])

    command("Gesture draw")
    command("normal! 10l")
    command("Gesture draw")
    command("normal! 10h")
    command("Gesture draw")
    command("Gesture finish")

    assert.window_count(1)
    assert.current_word("foo")
  end)

  it("can register and execute a nowait gesture", function()
    local gesture = require("gesture")
    gesture.register({inputs = {gesture.right()}, action = "normal! $", nowait = true})
    gesture.register({inputs = {gesture.right(), gesture.left()}, action = "normal! 0"})

    helper.set_lines([[
hoge         foo
]])

    command("Gesture draw")
    command("normal! 10l")
    command("Gesture draw")

    assert.window_count(1)
    assert.current_word("foo")
  end)

  it("can register and execute a nowait buffer local gesture", function()
    local gesture = require("gesture")
    gesture.register({inputs = {gesture.right()}, action = "normal! $", nowait = true, buffer = "%"})
    gesture.register({inputs = {gesture.right()}, action = "normal! 0", nowait = true})
    gesture.register({
      inputs = {gesture.right(), gesture.left()},
      action = "normal! 0",
      buffer = "%",
    })

    helper.set_lines([[
hoge         foo
]])

    command("Gesture draw")
    command("normal! 10l")
    command("Gesture draw")

    assert.window_count(1)
    assert.current_word("foo")
  end)

  it("does nothing for non matched gesture", function()
    local gesture = require("gesture")
    gesture.register({inputs = {gesture.down(), gesture.up()}, action = "normal! G"})

    helper.set_lines([[
hoge


foo]])

    command("Gesture draw")
    command("normal! 10j")
    command("Gesture draw")
    command("Gesture finish")

    assert.window_count(1)
    assert.current_line("hoge")
  end)

  it("can register a gesture with max length", function()
    local gesture = require("gesture")
    gesture.register({inputs = {gesture.right({max_length = 10})}, action = "normal! $"})

    helper.set_lines([[
hoge         foo
]])

    command("Gesture draw")
    command("normal! 11l")
    command("Gesture draw")
    command("Gesture finish")

    assert.window_count(1)
    assert.current_word("hoge")
  end)

  it("can register a gesture with min length", function()
    local gesture = require("gesture")
    gesture.register({inputs = {gesture.right({min_length = 10})}, action = "normal! $"})

    helper.set_lines([[
hoge         foo
]])

    command("Gesture draw")
    command("normal! 9l")
    command("Gesture draw")
    command("Gesture finish")

    assert.window_count(1)
    assert.current_word("hoge")
  end)

  it("shows input gestures", function()
    command("Gesture draw")
    command("normal! 10l")
    command("Gesture draw")
    command("normal! 10j")
    command("Gesture draw")
    command("normal! 10h")
    command("Gesture draw")
    command("normal! 10k")
    command("Gesture draw")

    assert.shown_in_view("RIGHT")
    assert.shown_in_view("DOWN")
    assert.shown_in_view("LEFT")
    assert.shown_in_view("UP")
  end)

  it("shows matched gesture name", function()
    local gesture = require("gesture")
    gesture.register({name = "to bottom", inputs = {gesture.down()}, action = "normal! G"})
    gesture.register({
      name = "to top",
      inputs = {gesture.down(), gesture.up()},
      action = "normal! gg",
    })

    command("Gesture draw")
    command("normal! 10j")
    command("Gesture draw")

    assert.shown_in_view("DOWN")
    assert.shown_in_view("to bottom")

    command("normal! 10k")
    command("Gesture draw")

    assert.shown_in_view("UP")
    assert.shown_in_view("to top")
  end)

  it("raises no error with many gestures", function()
    for _ = 0, 100, 1 do
      command("Gesture draw")
      command("normal! 10j")
      command("Gesture draw")
      command("normal! 10k")
    end
    assert.shown_in_view("UP")
  end)

  it("avoid creating multiple gesture state", function()
    command("tabedit")
    command("Gesture draw")
    command("noautocmd tabprevious")

    command("Gesture draw")
    command("tabnext")

    assert.window_count(1)
  end)

end)
