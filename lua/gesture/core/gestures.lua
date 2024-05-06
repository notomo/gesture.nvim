--- @class Gestures
--- @field private _gestures GestureInfo[]
local Gestures = {}
Gestures.__index = Gestures

function Gestures.new()
  local tbl = { _gestures = {} }
  return setmetatable(tbl, Gestures)
end

--- @param gesture GestureInfo
function Gestures.add(self, gesture)
  for i, g in ipairs(self._gestures) do
    if gesture.equals(g) then
      self._gestures[i] = gesture
      return
    end
  end
  table.insert(self._gestures, gesture)
end

--- @return boolean|string
function Gestures.can_match(self, ctx)
  for _, gesture in ipairs(self._gestures) do
    local matched_or_err = gesture:can_match(ctx)
    if matched_or_err then
      return matched_or_err
    end
  end
  return false
end

--- @return GestureInfo|nil|string
function Gestures.match(self, ctx)
  for _, gesture in ipairs(self._gestures) do
    local matched = gesture:match(ctx)
    if type(matched) == "string" then
      local err = matched
      return err
    end
    if matched then
      return gesture
    end
  end
  return nil
end

return Gestures
