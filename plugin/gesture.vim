if exists('g:loaded_gesture')
    finish
endif
let g:loaded_gesture = 1

command! -nargs=* Gesture lua require("gesture.command").main(<f-args>)
