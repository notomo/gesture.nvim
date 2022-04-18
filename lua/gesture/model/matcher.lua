local Matcher = {}
Matcher.__index = Matcher

function Matcher.new(gestureMap, bufnr)
  vim.validate({ bufnr = { bufnr, "number" }, gestureMap = { gestureMap, "table" } })
  local tbl = { _gesture_map = gestureMap, _bufnr = bufnr }
  return setmetatable(tbl, Matcher)
end

function Matcher.nowait_match(self, inputs)
  return self._gesture_map:match(self._bufnr, inputs, true)
end

function Matcher.match(self, inputs)
  return self._gesture_map:match(self._bufnr, inputs, false)
end

function Matcher.has_forward_match(self, inputs)
  return self._gesture_map:has_forward_match(self._bufnr, inputs)
end

return Matcher
