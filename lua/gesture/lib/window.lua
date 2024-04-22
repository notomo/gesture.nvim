local M = {}

function M.close(id)
  if not vim.api.nvim_win_is_valid(id) then
    return
  end
  vim.api.nvim_win_close(id, true)
end

function M.by_pattern(pattern)
  local bufnr = vim.fn.bufnr(pattern)
  if bufnr == -1 then
    return nil
  end
  return vim.fn.win_findbuf(bufnr)[1]
end

local is_in_window = function(window_id, global_position)
  local window_pos = vim.api.nvim_win_get_position(window_id)
  local row = global_position[1]

  local height = vim.api.nvim_win_get_height(window_id)
  local min_row = window_pos[1]
  local max_row = window_pos[1] + height

  if not (min_row <= row and row <= max_row) then
    return false
  end

  local col = global_position[2]
  local width = vim.api.nvim_win_get_width(window_id)
  local min_col = window_pos[2]
  local max_col = window_pos[2] + width
  return min_col <= col and col <= max_col
end

function M.from_global_position(tabpage, global_position, filter)
  local window_ids = vim.iter(vim.api.nvim_tabpage_list_wins(tabpage)):filter(filter):totable()

  local configs = {}
  for _, window_id in ipairs(window_ids) do
    configs[window_id] = vim.api.nvim_win_get_config(window_id)
  end

  local normal_window_ids = vim
    .iter(window_ids)
    :filter(function(window_id)
      return configs[window_id].relative == ""
    end)
    :totable()

  local floating_window_ids = vim
    .iter(window_ids)
    :filter(function(window_id)
      return configs[window_id].relative ~= ""
    end)
    :totable()

  local result_window_id
  for _, window_id in ipairs(normal_window_ids) do
    if is_in_window(window_id, global_position) then
      result_window_id = window_id
      break
    end
  end

  local result_zindex = -1
  for _, window_id in ipairs(floating_window_ids) do
    local zindex = configs[window_id].zindex
    if result_zindex < zindex and is_in_window(window_id, global_position) then
      result_window_id = window_id
    end
  end

  return result_window_id
end

return M
