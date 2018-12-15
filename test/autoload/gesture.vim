
let s:suite = themis#suite('gesture')
let s:assert = themis#helper('assert')

function! s:suite.before()
    let s:root = GestureTestBefore()
endfunction

function! s:suite.after_each()
    call GestureTestAfterEach()
endfunction

function! s:suite.draw()
    call gesture#register().down().right().noremap(":tabnew \<CR>")
    call gesture#register().down().noremap(":qa\<CR>")

    call gesture#draw()

    call s:assert.equals(&modified, v:true)

    normal! G

    call gesture#draw()

    normal! 30l

    call gesture#draw()

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 2)
    silent! tabclose
    call s:assert.equals(&modified, v:false)
endfunction

function! s:suite.save_modified()
    call gesture#register().down().noremap(":tabnew \<CR>")

    call append(1, 'modify')

    call gesture#draw()

    normal! G

    call gesture#draw()

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 2)
    silent! tabclose

    call s:assert.equals(&modified, v:true)

    silent! undo
    let lines = getbufline('%', 1, '$')
    call s:assert.equals(lines, [''])
    call s:assert.equals(&modified, v:false)
endfunction

function! s:suite.nowait()
    call gesture#register().down().right().noremap(":qa\<CR>")
    call gesture#register().down().noremap(":tabnew \<CR>", {'nowait' : v:true })

    call gesture#draw()

    call s:assert.equals(&modified, v:true)

    normal! G

    call gesture#draw()

    call s:assert.equals(tabpagenr('$'), 2)
    tabclose
    call s:assert.equals(&modified, v:false)
endfunction

function! s:suite.map()
    nnoremap F :<C-u>silent! tabnew<CR>
    call gesture#register().down().map('F')

    call gesture#draw()

    normal! G

    call gesture#draw()

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

        silent! tabnew
        call s:assert.equals(tabpagenr('$'), 2)
    endfunction

    let F = funcref('s:f')
    call gesture#register().right().left().down().up().func({ c -> F })

    call gesture#draw()

    normal! 30l

    call gesture#draw()

    normal! 30h

    call gesture#draw()

    normal! G

    call gesture#draw()

    normal! gg

    call gesture#draw()

    call gesture#finish()
endfunction

function! s:suite.buffer()
    call gesture#register().down().noremap(":qa\<CR>")
    call gesture#register().down().noremap(":tabnew \<CR>", { 'buffer' : v:true })
    call gesture#register().down().noremap(":qa\<CR>")

    call gesture#draw()

    normal! G

    call gesture#draw()

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 2)
endfunction

function! s:suite.other_buffer()
    call gesture#register().down().noremap(":tabnew \<CR>")

    silent! tabnew
    call gesture#register().down().noremap(":qa\<CR>", { 'buffer' : v:true })
    tabclose

    call gesture#draw()

    normal! G

    call gesture#draw()

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 2)
endfunction

function! s:suite.no_global()
    call gesture#register().down().noremap(":tabnew \<CR>", { 'buffer' : v:true })

    call gesture#draw()

    normal! G

    call gesture#draw()

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 2)
endfunction

function! s:suite.set_large_length_threshold()
    call gesture#custom#set('x_length_threshold', 1000)
    call gesture#custom#set('y_length_threshold', 1000)
    call gesture#register().down().noremap(":tabnew \<CR>", { 'nowait' : v:true })
    call gesture#register().right().noremap(":tabnew \<CR>", { 'nowait' : v:true })

    call gesture#draw()

    normal! G

    call gesture#draw()

    normal! 30l

    call gesture#draw()

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 1)
endfunction

function! s:suite.set_small_length_threshold()
    call gesture#custom#set('x_length_threshold', 1)
    call gesture#custom#set('y_length_threshold', 1)
    call gesture#register().down().noremap(":tabnew \<CR>", { 'nowait' : v:true })
    call gesture#register().right().noremap(":tabnew \<CR>", { 'nowait' : v:true })

    call gesture#draw()

    normal! j

    call gesture#draw()

    call s:assert.equals(tabpagenr('$'), 2)

    call gesture#draw()

    normal! l

    call gesture#draw()

    call s:assert.equals(tabpagenr('$'), 3)
endfunction

function! s:suite.get_inputs()
    call gesture#draw()

    normal! 5j

    call gesture#draw()

    normal! 5k

    call gesture#draw()

    call s:assert.equals(gesture#get_inputs(), [{'kind' : 'direction', 'value' : 'DOWN', 'length' : 5}, {'kind' : 'direction', 'value' : 'UP', 'length' : 5}])

    call gesture#finish()
endfunction

function! s:suite.draw_right_across_windows()
    call gesture#register().right().noremap(":tabnew \<CR>")

    execute 'vsplit ' . s:root . '/test/autoload/_test_data/long_row.txt'

    call gesture#draw()

    normal! G
    normal! M
    normal! 30l

    call gesture#draw()

    wincmd l
    normal! M
    normal! 30l

    call gesture#draw()

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 2)
    tabclose
endfunction

function! s:suite.draw_down_across_windows()
    set nostartofline

    call gesture#register().down().noremap(":tabnew \<CR>")

    execute 'split ' . s:root . '/test/autoload/_test_data/long_col.txt'

    normal! 30l

    call gesture#draw()

    normal! G

    call gesture#draw()

    wincmd j
    normal! 30l
    normal! G

    call gesture#draw()

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 2)
    tabclose

    set startofline
endfunction

function! s:suite.gesture_length_config()
    call gesture#register().right({'min_length':20}).noremap(":tabclose \<CR>")
    call gesture#register().right({'max_length':20}).noremap(":tabnew \<CR>")

    call gesture#draw()

    normal! 10l

    call gesture#draw()
    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 2)

    call gesture#draw()

    normal! 30l

    call gesture#draw()
    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 1)
endfunction

function! s:suite.gesture_length_config_with_range()
    call gesture#register().right({'max_length': 40, 'min_length':20}).noremap(":tabnew \<CR>")

    call gesture#draw()

    normal! 10l

    call gesture#draw()
    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 1)

    call gesture#draw()

    normal! 50l

    call gesture#draw()
    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 1)

    call gesture#draw()

    normal! 40l

    call gesture#draw()
    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 2)
endfunction

function! s:suite.cancel()
    call gesture#register().right().noremap(":tabnew \<CR>")

    call gesture#draw()

    normal! 30l

    call gesture#draw()

    call gesture#cancel()

    call s:assert.equals(tabpagenr('$'), 1)
    call s:assert.equals(gesture#get_inputs(), [])
endfunction

function! s:suite.input_text()
    call gesture#register().text('inputText').right().noremap(":tabnew \<CR>")

    call gesture#input_text('inputText')

    call gesture#draw()

    normal! 30l

    call gesture#draw()

    call s:assert.equals(gesture#get_inputs(), [{'kind' : 'text', 'value' : 'inputText', 'count' : 1}, {'kind' : 'direction', 'value' : 'RIGHT', 'length' : 30}])

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 2)
endfunction

function! s:suite.input_text_the_same_text()
    call gesture#register().right().text('inputText1', {'min_count' : 3, 'max_count': 3}).text('inputText2').left().noremap(":tabnew \<CR>")

    call gesture#draw()

    normal! 30l

    call gesture#draw()

    call gesture#input_text('inputText1')
    call gesture#input_text('inputText1')
    call gesture#input_text('inputText1')
    call gesture#input_text('inputText2')

    call gesture#draw()

    normal! 30h

    call gesture#draw()

    call s:assert.equals(gesture#get_inputs(), [
        \ {'kind' : 'direction', 'value' : 'RIGHT', 'length' : 30},
        \ {'kind' : 'text', 'value' : 'inputText1', 'count' : 3},
        \ {'kind' : 'text', 'value' : 'inputText2', 'count' : 1},
        \ {'kind' : 'direction', 'value' : 'LEFT', 'length' : 30},
    \ ])

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 2)
endfunction

function! s:suite.input_text_more_than_max()
    call gesture#register().text('inputText1', {'max_count': 3}).noremap(":tabnew \<CR>")

    call gesture#input_text('inputText1')
    call gesture#input_text('inputText1')
    call gesture#input_text('inputText1')
    call gesture#input_text('inputText1')

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 1)
endfunction

function! s:suite.input_text_less_than_min()
    call gesture#register().text('inputText1', {'min_count' : 3}).noremap(":tabnew \<CR>")

    call gesture#input_text('inputText1')
    call gesture#input_text('inputText1')

    call gesture#finish()

    call s:assert.equals(tabpagenr('$'), 1)
endfunction

function! s:suite.input_text_nowait()
    call gesture#register().text('inputText').noremap(":tabnew \<CR>", {'nowait' : v:true})

    call gesture#input_text('inputText')

    call s:assert.equals(tabpagenr('$'), 2)
endfunction

function! s:suite.invalid_text()
    let e = 'text must be a string except directions'

    try
        call gesture#register().text(1)
    catch /e/
        call s:assert.equals(gesture#get(), {})
    endtry

    try
        call gesture#register().text('LEFT')
    catch /e/
        call s:assert.equals(gesture#get(), {})
    endtry

    try
        call gesture#register().text('RIGHT')
    catch /e/
        call s:assert.equals(gesture#get(), {})
    endtry

    try
        call gesture#register().text('UP')
    catch /e/
        call s:assert.equals(gesture#get(), {})
    endtry

    try
        call gesture#register().text('DOWN')
    catch /e/
        call s:assert.equals(gesture#get(), {})
    endtry
endfunction
