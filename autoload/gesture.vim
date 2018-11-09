
function! gesture#execute() abort
    call _gesture_initialize()
    execute "normal! \<LeftMouse>"
    return _gesture_execute()
endfunction

function! gesture#finish() abort
    return _gesture_finish()
endfunction

let s:mapper = {}
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

    function! register.noremap(action, ...) abort
        let attributes = call('s:get_map_attributes', a:000)
        let nowait = attributes['nowait']

        call s:add(a:action, v:true, nowait, s:directions)
        let s:directions = []
    endfunction

    function! register.map(action, ...) abort
        let attributes = call('s:get_map_attributes', a:000)
        let nowait = attributes['nowait']

        call s:add(a:action, v:false, nowait, s:directions)
        let s:directions = []
    endfunction

    return register
endfunction

function! gesture#get_action(serialized_directions) abort
    if type(a:serialized_directions) != v:t_string
        throw 'serialized_directions must be a string'
    endif
    if !has_key(s:mapper, a:serialized_directions)
        return v:null
    endif
    return s:mapper[a:serialized_directions]['action']
endfunction

function! s:serialize_directions(directions) abort
    if type(a:directions) != v:t_list
        throw 'directions must be a list'
    endif

    let valid_directions = filter(map(copy(a:directions), {_, d -> v:t_string == type(d)}), {_, d -> d == 1})
    if len(valid_directions) != len(a:directions)
        throw 'directions must be a string list'
    endif

    return join(a:directions, ',')
endfunction

function! s:add(action, noremap, nowait, directions) abort
    if type(a:action) != v:t_string
        throw 'action must be a string'
    endif

    let serialized = s:serialize_directions(a:directions)
    let s:mapper[serialized] = {'action' : a:action, 'noremap' : a:noremap, 'nowait': a:nowait}
endfunction

function! s:get_map_attributes(...) abort
    let attributes = get(a:, 1, {})
    let nowait = get(attributes, 'nowait', v:false)
    return {'nowait' : nowait}
endfunction
