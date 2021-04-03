set mouse=a

nnoremap <silent> <LeftDrag> <Cmd>lua require("gesture").draw()<CR>
nnoremap <silent> <LeftRelease> <Cmd>lua require("gesture").finish()<CR>

" or if you would like to use right click
nnoremap <RightMouse> <Nop>
nnoremap <silent> <RightDrag> <Cmd>lua require("gesture").draw()<CR>
nnoremap <silent> <RightRelease> <Cmd>lua require("gesture").finish()<CR>

lua << EOF
local gesture = require('gesture')
gesture.register({
  name = "scroll to bottom",
  inputs = { gesture.up(), gesture.down() },
  action = "normal! G"
})
gesture.register({
  name = "next tab",
  inputs = { gesture.right() },
  action = "tabnext"
})
gesture.register({
  name = "previous tab",
  inputs = { gesture.left() },
  action = function() -- also can use function
    vim.cmd("tabprevious")
  end,
})
gesture.register({
  name = "go back",
  inputs = { gesture.right(), gesture.left() },
  -- map to `<C-o>` keycode
  action = [[lua vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-o>", true, false, true), "n", true)]]
})
EOF
