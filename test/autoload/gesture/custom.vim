
let s:suite = themis#suite('custom')
let s:assert = themis#helper('assert')

function! s:suite.before()
    let s:root = GestureTestBeforeEach()
endfunction

function! s:suite.after_each()
    call GestureTestAfterEach()
endfunction

function! s:suite.custom_set_and_get()
    let x_length_threshold = 8888
    call gesture#custom#set('x_length_threshold', x_length_threshold)

    call s:assert.equals(gesture#custom#get('x_length_threshold'), x_length_threshold)
endfunction

function! s:suite.clear()
    let default = gesture#custom#get('x_length_threshold')
    call gesture#custom#set('x_length_threshold', 0)

    call gesture#custom#clear()

    call s:assert.equals(gesture#custom#get('x_length_threshold'), default)
endfunction
