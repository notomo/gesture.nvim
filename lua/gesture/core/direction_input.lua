local Directions = require("gesture.core.directions")
local UP = Directions.UP
local DOWN = Directions.DOWN
local RIGHT = Directions.RIGHT
local LEFT = Directions.LEFT

local DirectionInput = {}

--- @param direction string
--- @param length integer
function DirectionInput.new(direction, length)
  return {
    direction = direction,
    length = length,
  }
end

function DirectionInput.from_points(p1, p2)
  local diff_x = p2.x - p1.x
  local length_x = math.abs(diff_x)

  local diff_y = p2.y - p1.y
  local length_y = math.abs(diff_y)

  local direction, length
  if length_x > length_y then
    direction = diff_x > 0 and RIGHT or LEFT
    length = length_x
  elseif length_y >= length_x and length_y > 0 then
    direction = diff_y > 0 and DOWN or UP
    length = length_y
  else
    return nil
  end

  return DirectionInput.new(direction, length)
end

--- @param input GestureInput
--- @param length_thresholds {x:number,y:number}
function DirectionInput.is_short(input, length_thresholds)
  if input.direction == UP or input.direction == DOWN then
    return input.length < length_thresholds.y
  end
  return input.length < length_thresholds.x
end

return DirectionInput
