-- This is used as datastore.
-- `modulelib.cleanup()` should ignore this module.
local M = {}

return function(key)
  local value = M[key]
  if value == nil then
    M[key] = {}
  end
  return M[key]
end
