doautocmd User GestureSourceLoad

function! gesture#draw() abort
    call _gesture_initialize(gesture#custom#get('enabled_buffer_fill'))

    let cursor_setter = gesture#custom#get('cursor_setter')
    if !empty(cursor_setter)
        execute cursor_setter
    endif

    let command_info = _gesture_execute('direction', v:null)
    return s:execute(command_info)
endfunction

function! gesture#input_text(text) abort
    if type(a:text) != v:t_string
        throw 'text must be a string'
    endif

    call _gesture_initialize(gesture#custom#get('enabled_buffer_fill'))
    let command_info = _gesture_execute('text', a:text)
    return s:execute(command_info)
endfunction

function! gesture#finish() abort
    let command_info = _gesture_finish()
    return s:execute(command_info)
endfunction

function! gesture#cancel() abort
    call _gesture_finish()
endfunction

let s:id = 0
let s:gestures = {}
let s:funcs = {}
function! gesture#register(...) abort

    let dict = call('s:get_gesture_attributes', a:000)

    function! dict.left(...) abort
        let attrs = call('s:get_line_attributes', a:000)
        let attrs['kind'] = 'direction'
        let attrs['value'] = 'LEFT'

        call add(self.inputs, attrs)
        return self
    endfunction

    function! dict.right(...) abort
        let attrs = call('s:get_line_attributes', a:000)
        let attrs['kind'] = 'direction'
        let attrs['value'] = 'RIGHT'

        call add(self.inputs, attrs)
        return self
    endfunction

    function! dict.down(...) abort
        let attrs = call('s:get_line_attributes', a:000)
        let attrs['kind'] = 'direction'
        let attrs['value'] = 'DOWN'

        call add(self.inputs, attrs)
        return self
    endfunction

    function! dict.up(...) abort
        let attrs = call('s:get_line_attributes', a:000)
        let attrs['kind'] = 'direction'
        let attrs['value'] = 'UP'

        call add(self.inputs, attrs)
        return self
    endfunction

    function! dict.text(text, ...) abort
        if type(a:text) != v:t_string
           \ || a:text ==# 'LEFT'
           \ || a:text ==# 'RIGHT'
           \ || a:text ==# 'DOWN'
           \ || a:text ==# 'UP'
            throw 'text must be a string except directions'
        endif

        let attrs = call('s:get_text_attributes', a:000)
        let attrs['kind'] = 'text'
        let attrs['value'] = a:text

        call add(self.inputs, attrs)
        return self
    endfunction

    function! dict.noremap(rhs, ...) abort
        if type(a:rhs) != v:t_string
            throw 'rhs must be a string'
        endif
        let gesture = call('s:get_map_attributes', a:000)
        let gesture['noremap'] = v:true
        let gesture['inputs'] = self.inputs
        let gesture['rhs'] = a:rhs
        let gesture['name'] = self.name

        call s:add_gesture(gesture)
    endfunction

    function! dict.map(rhs, ...) abort
        if type(a:rhs) != v:t_string
            throw 'rhs must be a string'
        endif
        let gesture = call('s:get_map_attributes', a:000)
        let gesture['noremap'] = v:false
        let gesture['inputs'] = self.inputs
        let gesture['rhs'] = a:rhs
        let gesture['name'] = self.name

        call s:add_gesture(gesture)
    endfunction

    function! dict.func(f, ...) abort
        if type(a:f) != v:t_func
            throw 'f must be a function'
        endif
        let gesture = call('s:get_map_attributes', a:000)
        let gesture['inputs'] = self.inputs
        let gesture['is_func'] = v:true
        let gesture['name'] = self.name

        let id = s:add_gesture(gesture)
        let s:funcs[id] = a:f
    endfunction

    return dict
endfunction

function! gesture#get_inputs() abort
    return _gesture_get_inputs()
endfunction

function! gesture#is_started() abort
    return !empty(_gesture_is_started())
endfunction

function! gesture#get() abort
    return s:gestures
endfunction

function! gesture#clear() abort
    let s:id = 0
    let s:gestures = {}
    let s:funcs = {}
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
        return v:false
    endif

    let action = a:command_info.action
    if action.is_func == v:false
        execute a:command_info.command
        return v:true
    endif

    if !has_key(s:funcs, action.id)
        return v:false
    endif

    call s:funcs[action.id](a:command_info.context)
    return v:true
endfunction

function! s:get_map_attributes(...) abort
    let attributes = get(a:, 1, {})

    let nowait = get(attributes, 'nowait', v:false)
    let silent = get(attributes, 'silent', v:false)
    let buffer = get(attributes, 'buffer', v:false)

    return {'rhs' : '', 'nowait' : nowait, 'silent' : silent, 'buffer' : buffer, 'is_func' : v:false}
endfunction

function! s:get_gesture_attributes(...) abort
    let attributes = get(a:, 1, {})

    let name = get(attributes, 'name', '')

    return {'name': name, 'inputs': []}
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

augroup gesture
    autocmd!
    autocmd InsertEnter * call gesture#cancel()
augroup END

highlight default link GestureInput NormalFloat
highlight default GestureNoAction guifg=#8d9eb2 ctermfg=103 guibg=#3a4b5c ctermbg=235
highlight default GestureActionLabel guifg=#a8d2eb ctermfg=153
