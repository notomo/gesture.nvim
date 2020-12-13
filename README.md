# gesture.nvim

[![ci](https://github.com/notomo/gesture.nvim/workflows/ci/badge.svg?branch=master)](https://github.com/notomo/gesture.nvim/actions?query=workflow%3Aci+branch%3Amaster)

gesture.nvim is a mouse gesture plugin for Neovim (nightly).

<img src="https://raw.github.com/wiki/notomo/gesture.nvim/images/gesture.gif" width="1280">

## Usage

```vim
set mouse=a
nnoremap <silent> <LeftDrag> <Cmd>Gesture draw<CR>
nnoremap <silent> <LeftRelease> <Cmd>Gesture finish<CR>
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
EOF
```
