if exists('g:loaded_gesture')
    finish
endif
let g:loaded_gesture = 1

if get(g:, 'gesture_debug', v:false)
    command! -nargs=* Gesture lua require("gesture/lib/cleanup")(); require("gesture/command").main(<f-args>)
else
    command! -nargs=* Gesture lua require("gesture/command").main(<f-args>)
endif
