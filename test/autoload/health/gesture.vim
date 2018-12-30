
let s:suite = themis#suite('health')
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

let s:ok_message = 'The compiled files are up to date.'
function! s:suite.check()
    execute 'checkhealth gesture'

    let line = search(s:ok_message, 'n')
    call s:assert.not_equals(line, 0)
endfunction

function! s:suite.valid_version()
    call health#gesture#_set_test_path(s:root . '/test/autoload/_test_data/valid_version')

    execute 'checkhealth gesture'

    let line = search(s:ok_message, 'n')
    call s:assert.not_equals(line, 0)
endfunction

function! s:suite.no_version_file()
    call health#gesture#_set_test_path(s:root . '/test/autoload/_test_data/no_lib')

    execute 'checkhealth gesture'

    let line = search('There are no compiled files.', 'n')
    call s:assert.not_equals(line, 0)
endfunction

function! s:suite.outdated_version()
    call health#gesture#_set_test_path(s:root . '/test/autoload/_test_data/outdated_version')

    execute 'checkhealth gesture'

    let line = search('The compiled files are outdated.', 'n')
    call s:assert.not_equals(line, 0)
endfunction
