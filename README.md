# gesture.nvim

[![ci](https://github.com/notomo/gesture.nvim/workflows/ci/badge.svg?branch=master)](https://github.com/notomo/gesture.nvim/actions?query=workflow%3Aci+branch%3Amaster)

gesture.nvim is a mouse gesture plugin for Neovim.

## Usage

```vim
nnoremap <silent> <LeftDrag> :<C-u>Gesture draw<CR>
nnoremap <silent> <LeftRelease> :<C-u>Gesture finish<CR>
```

```lua
local gesture = require('gesture')
gesture.register({
    name = "scroll to bottom",
    inputs = { gesture.up(), gesture.down() },
    action = "normal! G"
})
gesture.register({
    name = "scroll to top",
    inputs = { gesture.down(), gesture.up() },
    action = "normal! gg"
})
```
