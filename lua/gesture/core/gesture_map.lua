local vim = vim

local Gestures = require("gesture.core.gestures")
local GestureInfo = require("gesture.core.gesture_info")

local FOR_MATCH_STRS = { "_" }

--- @class GestureMap
--- @field private _map table<string,Gestures>
local GestureMap = {}
GestureMap.__index = GestureMap

function GestureMap.new()
  local tbl = {
    _map = {},
  }
  return setmetatable(tbl, GestureMap)
end

local make_key = function(bufnr, nowait, input_strs)
  local elements = {
    tostring(bufnr),
    tostring(nowait),
    table.concat(input_strs, "-"),
  }
  return table.concat(elements, "\t")
end

--- @param gesture GestureInfo
function GestureMap.add(self, gesture)
  local key = make_key(gesture.buffer, gesture.nowait, gesture.strs or FOR_MATCH_STRS)

  local gestures = self._map[key] or Gestures.new()
  gestures:add(gesture)

  self._map[key] = gestures
end

--- @param ctx GestureActionContext
function GestureMap.match(self, bufnr, ctx, nowait)
  vim.validate({
    bufnr = { bufnr, "number" },
    nowait = { nowait, "boolean" },
  })
  local input_strs = require("gesture.core.inputs").strings(ctx.inputs)

  local keys = {
    make_key(bufnr, nowait, FOR_MATCH_STRS),
    make_key(bufnr, nowait, input_strs),
    make_key(nil, nowait, FOR_MATCH_STRS),
    make_key(nil, nowait, input_strs),
  }
  for _, key in ipairs(keys) do
    local gesture = self:_match(key, ctx)
    if gesture then
      return gesture
    end
  end

  return nil
end

function GestureMap._match(self, key, ctx)
  local gestures = self._map[key]
  if not gestures then
    return nil
  end
  return gestures:match(ctx)
end

--- @return boolean|string
function GestureMap.can_match(self, bufnr, ctx)
  vim.validate({ bufnr = { bufnr, "number" } })
  local input_strs = require("gesture.core.inputs").strings(ctx.inputs)

  local key_pairs = {
    {
      make_key(bufnr, true, FOR_MATCH_STRS),
      make_key(bufnr, false, FOR_MATCH_STRS),
    },
    {
      make_key(bufnr, true, input_strs),
      make_key(bufnr, false, input_strs),
    },
    {
      make_key(nil, true, FOR_MATCH_STRS),
      make_key(nil, false, FOR_MATCH_STRS),
    },
    {
      make_key(nil, true, input_strs),
      make_key(nil, false, input_strs),
    },
  }
  for _, key_pair in ipairs(key_pairs) do
    local matched_or_err = self:_can_match(key_pair[1], key_pair[2], ctx)
    if matched_or_err then
      return matched_or_err
    end
  end

  return false
end

--- @return boolean|string
function GestureMap._can_match(self, nowait_key, key, ctx)
  for k, gestures in pairs(self._map) do
    local key_matched = vim.startswith(k, nowait_key) or vim.startswith(k, key)
    if key_matched then
      local matched_or_err = gestures:can_match(ctx)
      if matched_or_err then
        return matched_or_err
      end
    end
  end
  return false
end

local M = {}

M.store = GestureMap.new()

function M.clear()
  M.store = GestureMap.new()
end

function M.register(raw_info)
  M.store:add(GestureInfo.new(raw_info))
end

return M
