let g:node_host_prog = expand('<sfile>:h') . '/node_modules/neovim/bin/cli.js'
execute 'set runtimepath+=' . expand('<sfile>:h')
runtime! plugin/rplugin.vim
UpdateRemotePlugins
