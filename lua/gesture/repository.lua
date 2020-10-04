local persist = require("gesture/lib/_persist")("repository")

local M = {}

M.set = function(key, values)
  local new_values = {}
  for k, v in pairs(values) do
    new_values[k] = v
  end
  persist[key] = new_values
end

M.get = function(key)
  return persist[key]
end

M.delete = function(key)
  persist[key] = nil
end

return M
