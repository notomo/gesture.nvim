# gesture.nvim

[![Build Status](https://travis-ci.org/notomo/gesture.nvim.svg?branch=master)](https://travis-ci.org/notomo/gesture.nvim)
[![Build status](https://ci.appveyor.com/api/projects/status/ee3x3nl4jh207jjt/branch/master?svg=true)](https://ci.appveyor.com/project/notomo/gesture-nvim/branch/master)
[![codecov](https://codecov.io/gh/notomo/gesture.nvim/branch/master/graph/badge.svg)](https://codecov.io/gh/notomo/gesture.nvim)

gesture.nvim is a mouse gesture plugin for Neovim.

## Requirements
- Neovim
    - Node.js provider

## Install

```sh
# install Node.js provider
npm install -g neovim
```

### [minpac](https://github.com/k-takata/minpac)

```vim
call minpac#add('notomo/gesture.nvim', {'do' : '!npm run setup'})
```

### [dein.vim](https://github.com/Shougo/dein.vim)

```vim
call dein#add('notomo/gesture.nvim', {'build': 'npm run setup'})
```

or TOML configuration
```toml
[[plugins]]
repo = 'notomo/gesture.nvim'
build = 'npm run setup'
```

## Usage

```vim
nnoremap <silent> <LeftDrag> :<C-u>call gesture#draw()<CR>
nnoremap <silent> <LeftRelease> :<C-u>call gesture#finish()<CR>

" register gestures
call gesture#register().up().down().noremap('G')
call gesture#register().down().up().noremap('gg')
call gesture#register().left().noremap(":\<C-u>tabprevious\<CR>")
call gesture#register().right().noremap(":\<C-u>tabnext\<CR>")
```

For details, see `:help gesture.nvim-examples`.
