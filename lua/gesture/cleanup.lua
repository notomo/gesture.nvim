return function(name)
  local dir = name .. "/"
  for key in pairs(package.loaded) do
    if vim.startswith(key, dir) or key == name then
      package.loaded[key] = nil
    end
  end
  vim.api.nvim_command("doautocmd User GestureSourceLoad")
end
