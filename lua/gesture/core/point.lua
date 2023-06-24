local listlib = require("gesture.lib.list")

local Point = {}

function Point.new(x, y)
  return {
    x = x,
    y = y,
  }
end

local Y = function(p1, p2)
  local b = (p1.x * p2.y - p2.x * p1.y) / (p1.x - p2.x)
  local a = (p1.y - b) / p1.x
  return function(x)
    return a * x + b
  end
end

function Point.interpolate(p1, p2)
  local points = {}
  if p1.x == p2.x then
    local p_start = p1
    local p_end = p2
    local reverse = false
    if p1.y > p2.y then
      p_start = p2
      p_end = p1
      table.insert(points, p_start)
      reverse = true
    end

    local x = p_start.x
    local y = p_start.y + 1
    while y < p_end.y do
      table.insert(points, Point.new(x, y))
      y = y + 1
    end

    if reverse then
      return listlib.reverse(points)
    end
    table.insert(points, p_end)
    return points
  end

  local p_start = p1
  local p_end = p2
  local reverse = false
  if p1.x > p2.x then
    p_start = p2
    p_end = p1
    reverse = true
  end
  table.insert(points, p_start)

  local offset = 0.1
  local x = p_start.x + offset
  local get_y = Y(p_start, p_end)
  while x < p_end.x do
    local y = math.floor(get_y(x) + 0.5)
    local new = Point.new(math.floor(x + 0.5), y)
    local last = points[#points]
    if last.x ~= new.x or last.y ~= new.y then
      table.insert(points, new)
    end
    x = x + offset
  end

  if reverse then
    return listlib.reverse(points)
  end
  table.remove(points, 1)
  table.insert(points, p_end)
  return points
end

return Point
