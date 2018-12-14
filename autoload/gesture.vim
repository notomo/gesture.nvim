
if exists('*gesture#draw')
    finish
endif

function! gesture#draw() abort
    call _gesture_initialize()

    let cursor_setter = gesture#custom#get('cursor_setter')
    if !empty(cursor_setter)
        execute cursor_setter
    endif

    let command_info = _gesture_execute('direction', v:null)
    call s:execute(command_info)
endfunction

function! gesture#send(value) abort
    if type(a:value) != v:t_string
        throw 'value must be a string'
    endif

    call _gesture_execute('text', a:value)
endfunction

function! gesture#finish() abort
    let command_info = _gesture_finish()
    call s:execute(command_info)
endfunction

function! gesture#cancel() abort
    call _gesture_finish()
endfunction

let s:id = 0
let s:gestures = {}
let s:funcs = {}
function! gesture#register() abort

    let register = {}
    let s:inputs = []

    function! register.left(...) abort
        let attributes = call('s:get_line_attributes', a:000)
        let attributes['kind'] = 'direction'
        let attributes['value'] = 'LEFT'

        call add(s:inputs, attributes)
        return self
    endfunction

    function! register.right(...) abort
        let attributes = call('s:get_line_attributes', a:000)
        let attributes['kind'] = 'direction'
        let attributes['value'] = 'RIGHT'

        call add(s:inputs, attributes)
        return self
    endfunction

    function! register.down(...) abort
        let attributes = call('s:get_line_attributes', a:000)
        let attributes['kind'] = 'direction'
        let attributes['value'] = 'DOWN'

        call add(s:inputs, attributes)
        return self
    endfunction

    function! register.up(...) abort
        let attributes = call('s:get_line_attributes', a:000)
        let attributes['kind'] = 'direction'
        let attributes['value'] = 'UP'

        call add(s:inputs, attributes)
        return self
    endfunction

    function! register.text(value, ...) abort
        if type(a:value) != v:t_string
            throw 'value must be a string'
        endif

        let attributes = call('s:get_text_attributes', a:000)
        let attributes['kind'] = 'text'
        let attributes['value'] = a:value

        call add(s:inputs, attributes)
        return self
    endfunction

    function! register.noremap(rhs, ...) abort
        let attributes = call('s:get_map_attributes', a:000)
        let attributes['noremap'] = v:true

        call s:add(s:inputs, a:rhs, attributes)
        let s:inputs = []
    endfunction

    function! register.map(rhs, ...) abort
        let attributes = call('s:get_map_attributes', a:000)
        let attributes['noremap'] = v:false

        call s:add(s:inputs, a:rhs, attributes)
        let s:inputs = []
    endfunction

    function! register.func(f, ...) abort
        let attributes = call('s:get_map_attributes', a:000)

        call s:add_func(s:inputs, a:f, attributes)
        let s:inputs = []
    endfunction

    return register
endfunction

function! gesture#get_inputs() abort
    return _gesture_get_inputs()
endfunction

function! gesture#get() abort
    return s:gestures
endfunction

function! gesture#clear() abort
    let s:id = 0
    let s:gestures = {}
    let s:funcs = {}
endfunction

function! s:add(inputs, rhs, attributes) abort
    if type(a:rhs) != v:t_string
        throw 'rhs must be a string'
    endif

    let gesture = a:attributes
    let gesture['inputs'] = a:inputs
    let gesture['rhs'] = a:rhs

    call s:add_gesture(gesture)
endfunction

function! s:add_func(inputs, f, attributes) abort
    if type(a:f) != v:t_func
        throw 'f must be a function'
    endif

    let gesture = a:attributes
    let gesture['inputs'] = a:inputs
    let gesture['is_func'] = v:true

    let id = s:add_gesture(gesture)
    let s:funcs[id] = a:f
endfunction

function! s:add_gesture(gesture) abort
    let inputValues = map(a:gesture['inputs'][:], {_, v -> v['value']})

    let serialized = join(inputValues, ',')
    if !has_key(s:gestures, serialized)
        let s:gestures[serialized] = {}
        let s:gestures[serialized]['global'] = []
        let s:gestures[serialized]['buffer'] = {}
    endif

    let s:id += 1
    let a:gesture['id'] = s:id

    let buffer_id = bufnr('%')
    if a:gesture.buffer && buffer_id != -1
        if !has_key(s:gestures[serialized]['buffer'], buffer_id)
            let s:gestures[serialized]['buffer'][buffer_id] = []
        endif
        call add(s:gestures[serialized]['buffer'][buffer_id], a:gesture)
    else
        call add(s:gestures[serialized]['global'], a:gesture)
    endif

    return s:id
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
    let buffer = get(attributes, 'buffer', v:false)

    return {'rhs' : '', 'nowait' : nowait, 'silent' : silent, 'buffer' : buffer, 'is_func' : v:false}
endfunction

function! s:get_line_attributes(...) abort
    let attributes = get(a:, 1, {})

    let max_length = get(attributes, 'max_length', v:null)
    let min_length = get(attributes, 'min_length', v:null)

    return {'max_length' : max_length, 'min_length' : min_length}
endfunction

function! s:get_text_attributes(...) abort
    let attributes = get(a:, 1, {})

    let max_count = get(attributes, 'max_count', v:null)
    let min_count = get(attributes, 'min_count', v:null)

    return {'max_count' : max_count, 'min_count' : min_count}
endfunction
