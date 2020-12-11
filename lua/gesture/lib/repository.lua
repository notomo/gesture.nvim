local persist = {}

local M = {}

local Repository = {}
Repository.__index = Repository
M.Repository = Repository

function Repository.new(name)
  if persist[name] ~= nil then
    return persist[name]
  end
  local self = setmetatable({}, Repository)
  persist[name] = self
  return self
end

function Repository.get(self, key)
  return self[key]
end

function Repository.set(self, key, value)
  self[key] = value
end

function Repository.delete(self, key)
  self:set(key, nil)
end

return M
