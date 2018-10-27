
if exists('g:loaded_gesture')
    finish
endif
let g:loaded_gesture = 1

nnoremap <Plug>(gesture-execute) <LeftMouse>:<C-u>call gesture#execute()<CR>
nnoremap <Plug>(gesture-finish) :<C-u>call gesture#finish()<CR>
