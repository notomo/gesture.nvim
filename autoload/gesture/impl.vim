
" NOTICE: for windows workaround
function! gesture#impl#get_undolevels(buffer_id) abort
    return getbufvar(a:buffer_id, '&undolevels')
endfunction
