
function! health#gesture#check() abort
    call health#report_start('gesture.nvim')
    call s:check_ts_build()
endfunction

let s:project_root = expand('<sfile>:p:h:h:h')
let s:test_project_root = ''

function! s:check_ts_build() abort
    let project_root = empty(s:test_project_root) ? s:project_root : s:test_project_root
    let version_file = project_root . '/lib/version.json'

    let s:advice = [
        \ 'cd ' . fnamemodify(project_root, ':~'),
        \ 'npm run setup',
        \ 'Execute :UpdateRemotePlugins on neovim and restart neovim',
    \ ]

    if !filereadable(version_file)
        call health#report_error('There are no compiled files. Please execute the following commands.', s:advice)
        return
    endif

    let built_version_json = join(readfile(version_file), '')
    let built_versions = json_decode(built_version_json)

    let package_json = join(readfile(project_root . '/version.json'), '')
    let package_versions = json_decode(package_json)
    if built_versions == package_versions
        call health#report_ok('The compiled files are up to date.')
    else
        call health#report_warn('The compiled files are outdated. Please execute the following commands.', s:advice)
    endif
endfunction

function! health#gesture#_set_test_path(path) abort
    let s:test_project_root = a:path
endfunction
