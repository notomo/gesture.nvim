
function! gesture#execute() abort
    call _gesture_initialize()
    return _gesture_execute()
endfunction

function! gesture#finish() abort
    return _gesture_finish()
endfunction
