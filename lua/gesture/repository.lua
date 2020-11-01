local persist = {}

local M = {}

M.set = function(key, value)
  persist[key] = value
end

M.get = function(key)
  return persist[key]
end

M.delete = function(key)
  persist[key] = nil
end

return M
