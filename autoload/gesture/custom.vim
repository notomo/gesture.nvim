
let s:default_custom = {
    \ 'cursor_setter': "normal! \<LeftMouse>",
    \ 'x_length_threshold': 5,
    \ 'y_length_threshold': 5,
    \ 'enabled_buffer_fill': v:true,
\ }
let s:custom = deepcopy(s:default_custom)

let s:is_positive = {x -> (type(x) ==? v:t_number || type(x) ==? v:t_float) && x > 0}
let s:validations = {
    \ 'cursor_setter': {
        \ 'description': 'a command string',
        \ 'func': {x -> type(x) ==? v:t_string},
    \ },
    \ 'x_length_threshold': {
        \ 'description': 'a positive number',
        \ 'func': s:is_positive,
    \ },
    \ 'y_length_threshold': {
        \ 'description': 'a positive number',
        \ 'func': s:is_positive,
    \ },
    \ 'enabled_buffer_fill': {
        \ 'description': 'a bool',
        \ 'func': {x -> type(x) == v:t_bool},
    \ },
\ }

function! gesture#custom#set(key, value) abort
    if !has_key(s:custom, a:key)
        throw a:key . ' does not exist in custom options.'
    endif
    let validation = s:validations[a:key]
    if !validation['func'](a:value)
        throw a:key . ' must be ' . validation['description'] . '.'
    endif
    let s:custom[a:key] = a:value
endfunction

function! gesture#custom#get(key) abort
    if !has_key(s:custom, a:key)
        throw a:key . ' does not exist in custom options.'
    endif
    return s:custom[a:key]
endfunction

function! gesture#custom#clear() abort
    let s:custom = deepcopy(s:default_custom)
endfunction
