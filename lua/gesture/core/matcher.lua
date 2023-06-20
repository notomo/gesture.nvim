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

function Matcher.nowait_match(self, ctx, inputs)
  return self._gesture_map:match(self._bufnr, ctx, inputs, true)
end

function Matcher.match(self, ctx, inputs)
  return self._gesture_map:match(self._bufnr, ctx, inputs, false)
end

function Matcher.has_forward_match(self, inputs)
  return self._gesture_map:has_forward_match(self._bufnr, inputs)
end

return Matcher
