" Author: w0rp <devw0rp@gmail.com>, KabbAmine <amine.kabb@gmail.com>
" Description: This file adds support for checking Vim code with Vint.

" This flag can be used to change enable/disable style issues.
let g:ale_vim_vint_show_style_issues =
\   get(g:, 'ale_vim_vint_show_style_issues', 1)
let s:enable_neovim = has('nvim') ? ' --enable-neovim ' : ''
let s:format = '-f "{file_path}:{line_number}:{column_number}: {severity}: {description} (see {reference})"'
let s:vint_version = []

" always, yes, never
call ale#Set('vim_vint_executable', 'vint')
call ale#Set('vim_vint_use_docker', 'never')
call ale#Set('vim_vint_docker_image', 'rsrchboy/vint:latest')

function! ale_linters#vim#vint#VersionCommand(buffer) abort
    if empty(s:vint_version)
        " override the default entrypoint (our stdin helper shim)
        let l:save_run_cmd = ale#Var(a:buffer, 'docker_run_cmd')
        let b:ale_docker_run_cmd = l:save_run_cmd . ' --entrypoint="vint"'

        " Check the Vint version if we haven't checked it already.
        let l:version = ale#docker#RunCmd(a:buffer, 'vim_vint') . ' --version'
        let b:ale_docker_run_cmd = l:save_run_cmd

        return l:version
    endif

    return ''
endfunction

function! ale_linters#vim#vint#GetCommand(buffer, version_output) abort
    if empty(s:vint_version) && !empty(a:version_output)
        " Parse the version out of the --version output.
        let s:vint_version = ale#semver#Parse(join(a:version_output, "\n"))
    endif

    " Check the Vint version if we haven't checked it already.
    let l:command = ale#docker#RunCmd(a:buffer, 'vim_vint')

    let l:can_use_no_color_flag = empty(s:vint_version)
    \   || ale#semver#GreaterOrEqual(s:vint_version, [0, 3, 7])

    let l:warning_flag = ale#Var(a:buffer, 'vim_vint_show_style_issues') ? '-s' : '-w'

    return l:command . ' '
    \   . l:warning_flag . ' '
    \   . (l:can_use_no_color_flag ? '--no-color ' : '')
    \   . s:enable_neovim
    \   . s:format
    " \   . ' %t'
endfunction

function! ale_linters#vim#vint#GetExecutable(buffer) abort
    return ale#docker#GetBufExec(a:buffer, 'vim_vint')
endfunction

call ale#linter#Define('vim', {
\   'name': 'vint',
\   'executable_callback': 'ale_linters#vim#vint#GetExecutable',
\   'command_chain': [
\       {'callback': 'ale_linters#vim#vint#VersionCommand', 'output_stream': 'stderr'},
\       {'callback': 'ale_linters#vim#vint#GetCommand', 'read_buffer': 1, 'output_stream': 'stdout'},
\   ],
\   'read_buffer': 1,
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
