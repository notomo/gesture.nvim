
let s:suite = themis#suite('gesture')
let s:assert = themis#helper('assert')

function! s:suite.before()
    let s:root = GestureTestBefore()
endfunction

function! s:suite.after_each()
    call GestureTestAfterEach()
endfunction

function! s:suite.execute()
    call gesture#register().down().right().noremap(":tabnew\<CR>")
    call gesture#register().down().noremap(":qa\<CR>")

    call gesture#execute()

    call s:assert.equals(&modified, v:true)

    normal! G

    call gesture#execute()

    normal! 30l

    call gesture#execute()

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 2)
    tabclose
    call s:assert.equals(&modified, v:false)
endfunction

function! s:suite.save_modified()
    call gesture#register().down().noremap(":tabnew\<CR>")

    call append(1, 'modify')

    call gesture#execute()

    normal! G

    call gesture#execute()

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 2)
    tabclose

    call s:assert.equals(&modified, v:true)

    undo
    let lines = getbufline('%', 1, '$')
    call s:assert.equals(lines, [''])
endfunction

function! s:suite.nowait()
    call gesture#register().down().right().noremap(":qa\<CR>")
    call gesture#register().down().noremap(":tabnew\<CR>", {'nowait' : v:true })

    call gesture#execute()

    call s:assert.equals(&modified, v:true)

    normal! G

    call gesture#execute()

    call s:assert.equals(tabpagenr('$'), 2)
    tabclose
    call s:assert.equals(&modified, v:false)
endfunction

function! s:suite.map()
    nnoremap F :<C-u>tabnew<CR>
    call gesture#register().down().map('F')

    call gesture#execute()

    normal! G

    call gesture#execute()

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 2)

    unmap F
endfunction

function! s:suite.func()

    function! s:f(c) abort
        let window_id = win_getid()
        let buffer_id = bufnr('%')
        call s:assert.equals(window_id, a:c['windows'][0]['id'])
        call s:assert.equals(buffer_id, a:c['windows'][0]['bufferId'])

        tabnew
        call s:assert.equals(tabpagenr('$'), 2)
    endfunction

    let F = funcref('s:f')
    call gesture#register().right().left().down().up().func({c -> F })

    call gesture#execute()

    normal! 30l

    call gesture#execute()

    normal! 30h

    call gesture#execute()

    normal! G

    call gesture#execute()

    normal! gg

    call gesture#execute()

    call gesture#finish()
endfunction

function! s:suite.buffer()
    call gesture#register().down().noremap(":qa\<CR>")
    call gesture#register().down().noremap(":tabnew\<CR>", { 'buffer' : v:true })
    call gesture#register().down().noremap(":qa\<CR>")

    call gesture#execute()

    normal! G

    call gesture#execute()

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 2)
endfunction

function! s:suite.other_buffer()
    call gesture#register().down().noremap(":tabnew\<CR>")

    tabnew
    call gesture#register().down().noremap(":qa\<CR>", { 'buffer' : v:true })
    tabclose

    call gesture#execute()

    normal! G

    call gesture#execute()

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 2)
endfunction

function! s:suite.no_global()
    call gesture#register().down().noremap(":tabnew\<CR>", { 'buffer' : v:true })

    call gesture#execute()

    normal! G

    call gesture#execute()

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 2)
endfunction

function! s:suite.set_large_length_threshold()
    call gesture#custom('x_length_threshold', 1000)
    call gesture#custom('y_length_threshold', 1000)
    call gesture#register().down().noremap(":tabnew\<CR>", { 'nowait' : v:true })
    call gesture#register().right().noremap(":tabnew\<CR>", { 'nowait' : v:true })

    call gesture#execute()

    normal! G

    call gesture#execute()

    normal! 30l

    call gesture#execute()

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 1)
endfunction

function! s:suite.set_small_length_threshold()
    call gesture#custom('x_length_threshold', 1)
    call gesture#custom('y_length_threshold', 1)
    call gesture#register().down().noremap(":tabnew\<CR>", { 'nowait' : v:true })
    call gesture#register().right().noremap(":tabnew\<CR>", { 'nowait' : v:true })

    call gesture#execute()

    normal! j

    call gesture#execute()

    call s:assert.equals(tabpagenr('$'), 2)

    call gesture#execute()

    normal! l

    call gesture#execute()

    call s:assert.equals(tabpagenr('$'), 3)
endfunction
