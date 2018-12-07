
function! gesture#execute() abort
    call _gesture_initialize()
    let cursor_setter = gesture#get_custom('cursor_setter')
    if !empty(cursor_setter)
        execute cursor_setter
    endif
    let command_info = _gesture_execute()
    call s:execute(command_info)
endfunction

function! gesture#finish() abort
    let command_info = _gesture_finish()
    call s:execute(command_info)
endfunction

let s:id = 0
let s:gestures = {}
let s:funcs = {}
function! gesture#register() abort

    let register = {}
    let s:directions = []

    function! register.left() abort
        call add(s:directions, 'LEFT')
        return self
    endfunction

    function! register.right() abort
        call add(s:directions, 'RIGHT')
        return self
    endfunction

    function! register.down() abort
        call add(s:directions, 'DOWN')
        return self
    endfunction

    function! register.up() abort
        call add(s:directions, 'UP')
        return self
    endfunction

    function! register.noremap(rhs, ...) abort
        let attributes = call('s:get_map_attributes', a:000)
        let attributes['noremap'] = v:true

        call s:add(s:directions, a:rhs, attributes)
        let s:directions = []
    endfunction

    function! register.map(rhs, ...) abort
        let attributes = call('s:get_map_attributes', a:000)
        let attributes['noremap'] = v:false

        call s:add(s:directions, a:rhs, attributes)
        let s:directions = []
    endfunction

    function! register.func(f, ...) abort
        let attributes = call('s:get_map_attributes', a:000)

        call s:add_func(s:directions, a:f, attributes)
        let s:directions = []
    endfunction

    return register
endfunction

function! gesture#get() abort
    return s:gestures
endfunction

function! gesture#clear() abort
    let s:id = 0
    let s:gestures = {}
    let s:funcs = {}
endfunction

let s:default_custom = {
    \ 'cursor_setter': "normal! \<LeftMouse>",
\ }
let s:custom = s:default_custom

function! gesture#custom(key, value) abort
    if !has_key(s:custom, a:key)
        throw a:key . ' does not exist in custom options.'
    endif
    let s:custom[a:key] = a:value
endfunction

function! gesture#get_custom(key) abort
    if !has_key(s:custom, a:key)
        throw a:key . ' does not exist in custom options.'
    endif
    return s:custom[a:key]
endfunction


function! s:add(directions, rhs, attributes) abort
    if type(a:rhs) != v:t_string
        throw 'rhs must be a string'
    endif

    let gesture = a:attributes
    let gesture['directions'] = a:directions
    let gesture['rhs'] = a:rhs

    call s:add_gesture(a:directions, gesture)
endfunction

function! s:add_func(directions, f, attributes) abort
    if type(a:f) != v:t_func
        throw 'f must be a function'
    endif

    let gesture = a:attributes
    let gesture['directions'] = a:directions
    let gesture['is_func'] = v:true

    let id = s:add_gesture(a:directions, gesture)
    let s:funcs[id] = a:f
endfunction

function! s:add_gesture(directions, gesture) abort
    let serialized = join(a:directions, ',')
    if !has_key(s:gestures, serialized)
        let s:gestures[serialized] = {}
    endif

    let id = s:id + 1
    let a:gesture['id'] = id

    let s:gestures[serialized]['global'] = a:gesture

    return id
endfunction

function! s:execute(command_info) abort
    if empty(a:command_info)
        return
    endif

    let action = a:command_info.action
    if action.is_func == v:false
        execute a:command_info.command
        return
    endif

    if !has_key(s:funcs, action.id)
        return
    endif

    call s:funcs[action.id](a:command_info.context)
endfunction

function! s:get_map_attributes(...) abort
    let attributes = get(a:, 1, {})

    let nowait = get(attributes, 'nowait', v:false)
    let silent = get(attributes, 'silent', v:false)

    return {'rhs' : '', 'nowait' : nowait, 'silent' : silent, 'is_func' : v:false}
endfunction
