local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
return function()
  local dir = plugin_name .. "/"
  local dot = plugin_name .. "."
  for key in pairs(package.loaded) do
    if (vim.startswith(key, dir) or vim.startswith(key, dot) or key == plugin_name) then
      package.loaded[key] = nil
    end
  end
end
