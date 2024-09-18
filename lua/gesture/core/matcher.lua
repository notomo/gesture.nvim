--- @class GestureMatcher
--- @field private _gesture_map GestureMap
--- @field private _bufnr integer
local Matcher = {}
Matcher.__index = Matcher

--- @param bufnr integer
function Matcher.new(bufnr)
  local tbl = {
    _gesture_map = require("gesture.core.gesture_map").store,
    _bufnr = bufnr,
  }
  return setmetatable(tbl, Matcher)
end

function Matcher.nowait_match(self, ctx, can_match)
  if not can_match then
    return nil
  end
  return self._gesture_map:match(self._bufnr, ctx, true)
end

function Matcher.match(self, ctx, can_match)
  if not can_match then
    return nil
  end
  return self._gesture_map:match(self._bufnr, ctx, false)
end

function Matcher.can_match(self, ctx)
  return self._gesture_map:can_match(self._bufnr, ctx)
end

return Matcher
