local Gestures = {}
Gestures.__index = Gestures

function Gestures.new()
  local tbl = { _gestures = {} }
  return setmetatable(tbl, Gestures)
end

function Gestures.add(self, gesture)
  for i, g in ipairs(self._gestures) do
    if gesture.equals(g) then
      self._gestures[i] = gesture
      return
    end
  end
  table.insert(self._gestures, gesture)
end

function Gestures.can_match(self, ctx)
  for _, gesture in ipairs(self._gestures) do
    if gesture.can_match(ctx) then
      return true
    end
  end
  return false
end

function Gestures.match(self, ctx)
  for _, gesture in ipairs(self._gestures) do
    if gesture.can_match(ctx) and gesture.match(ctx) then
      return gesture
    end
  end
  return nil
end

return Gestures
