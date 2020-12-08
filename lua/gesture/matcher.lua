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
  return gestures.map:get(self._bufnr):match(inputs, true)
end

function Matcher.match(self, inputs)
  return gestures.map:get(self._bufnr):match(inputs, false)
end

function Matcher.has_forward_match(self, inputs)
  return gestures.map:get(self._bufnr):has_forward_match(inputs)
end

return M
