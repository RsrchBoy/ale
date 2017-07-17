" Author: w0rp <devw0rp@gmail.com>, KabbAmine <amine.kabb@gmail.com>
" Description: This file adds support for checking Vim code with Vint.

let s:linter = 'vim_vint'

" This flag can be used to change enable/disable style issues.
let g:ale_vim_vint_show_style_issues =
\   get(g:, 'ale_vim_vint_show_style_issues', 1)
let s:enable_neovim = has('nvim') ? ' --enable-neovim ' : ''
let s:format = '-f "{file_path}:{line_number}:{column_number}: {severity}: {description} (see {reference})"'
let s:vint_version = []

call ale#linter#util#SetStandardVars(s:linter, 'vint', 'rsrchboy/vint:latest')

function! ale_linters#vim#vint#VersionCommand(buffer) abort
    if empty(s:vint_version)

        " Check the Vint version if we haven't checked it already.
        let l:version = ale#docker#PrepareRunCmd(a:buffer, s:linter,
        \ ale#Var(a:buffer, s:linter.'_executable') . ' --version')

        return l:version
    endif

    return ''
endfunction

function! ale_linters#vim#vint#GetCommand(buffer, version_output) abort
    if empty(s:vint_version) && !empty(a:version_output)
        " Parse the version out of the --version output.
        let s:vint_version = ale#semver#Parse(join(a:version_output, "\n"))
    endif

    let l:can_use_no_color_flag = empty(s:vint_version)
    \   || ale#semver#GreaterOrEqual(s:vint_version, [0, 3, 7])

    let l:warning_flag = ale#Var(a:buffer, 'vim_vint_show_style_issues') ? '-s' : '-w'

    let l:command = ale#Var(a:buffer, s:linter.'_executable') . ' '
    \   . l:warning_flag . ' '
    \   . (l:can_use_no_color_flag ? '--no-color ' : '')
    \   . s:enable_neovim
    \   . s:format
    \   . ' %t'

    " Check the Vint version if we haven't checked it already.
    let l:command = ale#docker#PrepareRunCmd(a:buffer, s:linter, l:command)

    return l:command
endfunction

call ale#linter#Define('vim', {
\   'name': 'vint',
\   'executable_callback': { buffer -> ale#linter#util#GetBufExec(buffer, s:linter) },
\   'command_chain': [
\       {'callback': 'ale_linters#vim#vint#VersionCommand', 'output_stream': 'stderr'},
\       {'callback': 'ale_linters#vim#vint#GetCommand', 'read_buffer': 1, 'output_stream': 'stdout'},
\   ],
\   'read_buffer': 1,
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
