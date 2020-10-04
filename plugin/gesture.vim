if exists('g:loaded_gesture')
    finish
endif
let g:loaded_gesture = 1

if get(g:, 'gesture_debug', v:false)
    command! -nargs=* Gesture lua require("gesture/lib/cleanup")(); require("gesture/command").main(<f-args>)
else
    command! -nargs=* Gesture lua require("gesture/command").main(<f-args>)
endif

highlight default GestureInput ctermfg=230 ctermbg=235 gui=bold guifg=#fffeeb guibg=#3a4b5c blend=0
highlight default GestureNoAction guifg=#8d9eb2 ctermfg=103 guibg=#3a4b5c ctermbg=235 blend=0
highlight default GestureActionLabel gui=bold guifg=#a8d2eb ctermfg=153 blend=0
highlight default GestureLine ctermbg=153 guibg=#a8d2eb blend=0
