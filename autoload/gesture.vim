
function! gesture#execute() abort
    call _gesture_initialize()
    execute "normal! \<LeftMouse>"
    return _gesture_execute()
endfunction

function! gesture#finish() abort
    return _gesture_finish()
endfunction
