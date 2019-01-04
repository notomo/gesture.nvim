
let s:suite = themis#suite('custom')
let s:assert = themis#helper('assert')

function! s:suite.before()
    let s:root = GestureTestBefore()
endfunction

function! s:suite.before_each()
    call GestureTestBeforeEach()
endfunction

function! s:suite.after_each()
    call GestureTestAfterEach()
endfunction

function! s:suite.custom_set_and_get()
    let cursor_setter = 'echomsg "test"'
    call gesture#custom#set('cursor_setter', cursor_setter)

    call s:assert.equals(gesture#custom#get('cursor_setter'), cursor_setter)

    let x_length_threshold = 8888
    call gesture#custom#set('x_length_threshold', x_length_threshold)

    call s:assert.equals(gesture#custom#get('x_length_threshold'), x_length_threshold)

    let y_length_threshold = 9999
    call gesture#custom#set('y_length_threshold', y_length_threshold)

    call s:assert.equals(gesture#custom#get('y_length_threshold'), y_length_threshold)

    let enabled_buffer_fill = v:false
    call gesture#custom#set('enabled_buffer_fill', enabled_buffer_fill)

    call s:assert.equals(gesture#custom#get('enabled_buffer_fill'), enabled_buffer_fill)
endfunction

function! s:suite.clear()
    let default = gesture#custom#get('x_length_threshold')
    call gesture#custom#set('x_length_threshold', 8888)

    call gesture#custom#clear()

    call s:assert.equals(gesture#custom#get('x_length_threshold'), default)
endfunction

function! s:suite.set_invalid_key()
    try
        call gesture#custom#set('invalid_key', 1)
    catch /invalid_key does not exist in custom options./
    endtry
endfunction

function! s:suite.set_invalid_value()
    try
        call gesture#custom#set('cursor_setter', 0)
    catch /cursor_setter must be a command string./
    endtry

    try
        call gesture#custom#set('x_length_threshold', 'invalid_value')
    catch /x_length_threshold must be a positive number./
    endtry

    try
        call gesture#custom#set('y_length_threshold', 'invalid_value')
    catch /y_length_threshold must be a positive number./
    endtry

    try
        call gesture#custom#set('enabled_buffer_fill', 'invalid_value')
    catch /enabled_buffer_fill must be a bool./
    endtry
endfunction
