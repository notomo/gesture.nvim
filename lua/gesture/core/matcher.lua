local Matcher = {}
Matcher.__index = Matcher

function Matcher.new(bufnr)
  vim.validate({
    bufnr = { bufnr, "number" },
  })
  local tbl = {
    _gesture_map = require("gesture.core.gesture").map,
    _bufnr = bufnr,
  }
  return setmetatable(tbl, Matcher)
end

function Matcher.nowait_match(self, ctx)
  return self._gesture_map:match(self._bufnr, ctx, true)
end

function Matcher.match(self, ctx)
  return self._gesture_map:match(self._bufnr, ctx, false)
end

function Matcher.can_match(self, ctx)
  return self._gesture_map:can_match(self._bufnr, ctx)
end

return Matcher
