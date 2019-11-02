if exists('g:loaded_gesture')
    finish
endif
let g:loaded_gesture = 1

command! GestureDraw call gesture#draw()
command! GestureFinish call gesture#finish()
