local gestures = require("gesture")

local M = {}

local Matcher = {}
Matcher.__index = Matcher
M.Matcher = Matcher

function Matcher.new(bufnr)
  vim.validate({bufnr = {bufnr, "number"}})
  local tbl = {_bufnr = bufnr}
  return setmetatable(tbl, Matcher)
end

function Matcher.nowait_match(self, inputs)
  return gestures.map:match(self._bufnr, inputs, true)
end

function Matcher.match(self, inputs)
  return gestures.map:match(self._bufnr, inputs, false)
end

function Matcher.has_forward_match(self, inputs)
  return gestures.map:has_forward_match(self._bufnr, inputs)
end

return M
