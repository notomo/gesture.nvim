
function! gesture#execute() abort
    call _gesture_initialize()
    execute "normal! \<LeftMouse>"
    return _gesture_execute()
endfunction

function! gesture#finish() abort
    return _gesture_finish()
endfunction

let s:mapper = {}
function! gesture#register(directions, action) abort
    if type(a:action) != v:t_string
        throw 'action must be a string'
    endif
    let serialized = s:serialize_directions(a:directions)
    let s:mapper[serialized] = a:action
endfunction

function! gesture#get_action(serialized_directions) abort
    if type(a:serialized_directions) != v:t_string
        throw 'serialized_directions must be a string'
    endif
    if !has_key(s:mapper, a:serialized_directions)
        return v:null
    endif
    return s:mapper[a:serialized_directions]
endfunction

function! s:serialize_directions(directions) abort
    if type(a:directions) != v:t_list
        throw 'directions must be a list'
    endif

    let valid_directions = filter(map(copy(a:directions), {_, d -> v:t_string == type(d)}), {_, d -> d == 1})
    if len(valid_directions) != len(a:directions)
        throw 'directions must be a string list'
    endif

    return join(a:directions, ",")
endfunction
