if exists('g:loaded_gesture')
    finish
endif
let g:loaded_gesture = 1

command! GestureDraw call gesture#draw()
command! GestureFinish call gesture#finish()

if get(g:, 'gesture_debug', v:false)
    command! -nargs=* Gesture lua require("gesture/cleanup")("gesture"); require("gesture/command").main(<f-args>)
else
    command! -nargs=* Gesture lua require("gesture/command").main(<f-args>)
endif
