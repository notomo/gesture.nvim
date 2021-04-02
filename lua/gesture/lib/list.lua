local M = {}

-- NOTE: keeps metatable unlike vim.fn.reverse(tbl)
function M.reverse(tbl)
  local new_tbl = {}
  for i = #tbl, 1, -1 do
    table.insert(new_tbl, tbl[i])
  end
  return new_tbl
end

function M.wrap(strs, width, separator)
  separator = separator or " "
  local wrapped = {}
  for _, str in ipairs(strs) do
    local last = wrapped[#wrapped]
    if last == nil or #last + #separator + #str > width then
      table.insert(wrapped, str)
    else
      wrapped[#wrapped] = table.concat({last, str}, separator)
    end
  end
  return wrapped
end

return M
