local Matcher = {}
Matcher.__index = Matcher

function Matcher.new(gesture_map, bufnr)
  vim.validate({
    bufnr = { bufnr, "number" },
    gesture_map = { gesture_map, "table" },
  })
  local tbl = {
    _gesture_map = gesture_map,
    _bufnr = bufnr,
  }
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
