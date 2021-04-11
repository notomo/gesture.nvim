local M = {}

function M.to_virtual_texts(ranges)
  local virtual_texts = {}
  local col = 1
  for _, range in ipairs(ranges) do
    local s = range[1]
    local e = range[2]
    local before_space = s - col
    if before_space > 0 then
      local space = (" "):rep(before_space)
      table.insert(virtual_texts, {space})
    end
    local hl_group = range[3]
    local space = (" "):rep(e - s + 1)
    table.insert(virtual_texts, {space, hl_group})
    col = e + 1
  end
  return virtual_texts
end

function M.board_to_virtual_texts(ranges)
  local virtual_texts = {}
  for _, range in ipairs(ranges) do
    local hl_group = range[3]
    local text = range[4]
    if text ~= nil then
      table.insert(virtual_texts, {text, hl_group})
    else
      local s = range[1]
      local e = range[2]
      local space = (" "):rep(e - s + 1)
      table.insert(virtual_texts, {space, hl_group})
    end
  end
  local first = ranges[1] or {0, 0}
  return first[1], virtual_texts
end

return M
