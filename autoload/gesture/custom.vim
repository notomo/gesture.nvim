
let s:default_custom = {
    \ 'cursor_setter': "normal! \<LeftMouse>",
    \ 'x_length_threshold': 5,
    \ 'y_length_threshold': 5,
\ }
let s:custom = deepcopy(s:default_custom)

function! gesture#custom#set(key, value) abort
    if !has_key(s:custom, a:key)
        throw a:key . ' does not exist in custom options.'
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
