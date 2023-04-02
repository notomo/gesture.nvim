local M = {}

--- @class GestureDrawOption
--- @field show_board? boolean show inputted directions and matched gesture name (default: true)

--- Draw a gesture line.
--- @param opts GestureDrawOption? |GestureDrawOption|
function M.draw(opts)
  require("gesture.command").draw(opts)
end

--- Suspend gesture.
function M.suspend()
  require("gesture.command").suspend()
end

--- Finish the gesture and execute matched action.
function M.finish()
  require("gesture.command").finish()
end

--- Cancel the gesture.
function M.cancel()
  require("gesture.command").cancel()
end

--- @class GestureInfo
--- @field name string? a displayed name
--- @field inputs GestureInput[] inputs definition
--- @field action string|fun(ctx:GestureActionContext)|table an action executed on matched. can use callable table.
--- @field nowait boolean? to define nowait gesture
--- @field buffer (string|number)? to define the buffer local gesture

--- @class GestureActionContext
--- @field last_position integer[] tha last position drawn by gesture

--- Register a gesture.
--- @param info GestureInfo: |GestureInfo|
function M.register(info)
  require("gesture.command").register(info)
end

--- Clear the registered gestures.
function M.clear()
  require("gesture.command").clear()
end

--- @class GestureInputOption
--- @field max_length integer? max length of the input line
--- @field min_length integer? min length of the input line

--- @class GestureInput

--- Up input
--- @param opts GestureInputOption?: |GestureInputOption|
--- @return GestureInput # used as an element of |GestureInfo|'s inputs
function M.up(opts)
  return require("gesture.core.direction").up(opts)
end

--- Down input
--- @param opts GestureInputOption?: |GestureInputOption|
--- @return GestureInput # used as an element of |GestureInfo|'s inputs
function M.down(opts)
  return require("gesture.core.direction").down(opts)
end

--- Right input
--- @param opts GestureInputOption?: |GestureInputOption|
--- @return GestureInput # used as an element of |GestureInfo|'s inputs
function M.right(opts)
  return require("gesture.core.direction").right(opts)
end

--- Left input
--- @param opts GestureInputOption?: |GestureInputOption|
--- @return GestureInput # used as an element of |GestureInfo|'s inputs
function M.left(opts)
  return require("gesture.core.direction").left(opts)
end

return M
