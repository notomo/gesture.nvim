local helper = require "test.helper"
local assert = helper.assert
local command = helper.command

describe('gesture.nvim', function ()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it('can register and execute a gesture', function ()
    local gesture = require('gesture')
    gesture.register({
      inputs={ gesture.down(), gesture.up() },
      action="normal! gg"
    })

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
end)
