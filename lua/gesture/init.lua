local M = {}

--- @class GestureLengthThresholds
--- @field x integer? x axis length threshold
--- @field y integer? y axis length threshold

--- @class GestureDrawOption
--- @field show_board? boolean show inputted directions and matched gesture name (default: true)
--- @field winblend? integer background window's 'winblend' (default: 100)
--- @field length_thresholds? GestureLengthThresholds recognize as input if its length is greater than threshold. |GestureLengthThresholds|

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

--- - Prefers `match` over `inputs`.
--- - Prefers `can_match` over `inputs`.
--- @class GestureInfo
--- @field name string? a displayed name
--- @field inputs GestureInputDefinition[]? ref: |GestureInputDefinition|
--- @field match (fun(ctx:GestureActionContext):boolean)? This is called on every |gesture.draw()| and |gesture.finish()|. If returns true, it means the gesture matches current context.
--- @field can_match (fun(ctx:GestureActionContext):boolean)? This is called on every |gesture.draw()|. If returns false, it means the gesture can not match anymore.
--- @field action string|fun(ctx:GestureActionContext)|table an action executed on matched. can use callable table.
--- @field nowait boolean? to define nowait gesture
--- @field buffer (string|integer)? to define the buffer local gesture

--- @class GestureActionContext
--- @field last_position integer[] the last position drawn by gesture
--- @field window_ids integer[] window ids that gesture traces
--- @field inputs GestureInput[] ref: |GestureInput|

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
--- @field direction "UP"|"DOWN"|"LEFT"|"RIGHT"
--- @field length integer

--- @class GestureInputDefinition

--- Up input
--- @param opts GestureInputOption?: |GestureInputOption|
--- @return GestureInputDefinition # used as an element of |GestureInfo|'s inputs
function M.up(opts)
  return require("gesture.core.direction_input_definition").up(opts)
end

--- Down input
--- @param opts GestureInputOption?: |GestureInputOption|
--- @return GestureInputDefinition # used as an element of |GestureInfo|'s inputs
function M.down(opts)
  return require("gesture.core.direction_input_definition").down(opts)
end

--- Right input
--- @param opts GestureInputOption?: |GestureInputOption|
--- @return GestureInputDefinition # used as an element of |GestureInfo|'s inputs
function M.right(opts)
  return require("gesture.core.direction_input_definition").right(opts)
end

--- Left input
--- @param opts GestureInputOption?: |GestureInputOption|
--- @return GestureInputDefinition # used as an element of |GestureInfo|'s inputs
function M.left(opts)
  return require("gesture.core.direction_input_definition").left(opts)
end

return M
