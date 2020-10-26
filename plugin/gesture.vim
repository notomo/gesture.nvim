if exists('g:loaded_gesture')
    finish
endif
let g:loaded_gesture = 1

command! -nargs=* Gesture lua require("gesture/command").main(<f-args>)

if get(g:, 'gesture_debug', v:false)
    augroup gesture_dev
        autocmd!
        execute 'autocmd BufWritePost' expand('<sfile>:p:h:h') .. '/*' 'lua require("gesture/lib/cleanup")()'
    augroup END
endif
