local M = {}

-- NOTE: keeps metatable unlike vim.fn.reverse(tbl)
M.reverse = function(tbl)
  local new_tbl = {}
  for i = #tbl, 1, -1 do
    table.insert(new_tbl, tbl[i])
  end
  return new_tbl
end

return M
