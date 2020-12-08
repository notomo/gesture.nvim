local gestures = require("gesture")

local M = {}

local Mapper = {}
Mapper.__index = Mapper
M.Mapper = Mapper

function Mapper.new(bufnr)
  vim.validate({bufnr = {bufnr, "number"}})
  local tbl = {_bufnr = bufnr}
  return setmetatable(tbl, Mapper)
end

function Mapper.nowait_match(self, inputs)
  return gestures.map:get(self._bufnr):match(inputs, true)
end

function Mapper.match(self, inputs)
  return gestures.map:get(self._bufnr):match(inputs, false)
end

function Mapper.has_forward_match(self, inputs)
  return gestures.map:get(self._bufnr):has_forward_match(inputs)
end

return M
