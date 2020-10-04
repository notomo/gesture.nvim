local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]

return function()
  local dir = plugin_name .. "/"
  for key in pairs(package.loaded) do
    if (vim.startswith(key, dir) or key == plugin_name) and key ~= "gesture/lib/_persist" then
      package.loaded[key] = nil
    end
  end
  vim.api.nvim_command("doautocmd User GestureSourceLoad")
end
