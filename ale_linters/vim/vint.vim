" Author: w0rp <devw0rp@gmail.com>, KabbAmine <amine.kabb@gmail.com>
" Description: This file adds support for checking Vim code with Vint.

" This flag can be used to change enable/disable style issues.
let g:ale_vim_vint_show_style_issues =
\   get(g:, 'ale_vim_vint_show_style_issues', 1)
let s:enable_neovim = has('nvim') ? ' --enable-neovim ' : ''
let s:format = '-f "{file_path}:{line_number}:{column_number}: {severity}: {description} (see {reference})"'
let s:vint_version = []

" always, yes, never
call ale#Set('vim_vint_use_docker', 'never')
call ale#Set('vim_vint_docker_image', 'rsrchboy/vint')

function! ale_linters#vim#vint#VersionCommand(buffer) abort
    if empty(s:vint_version)
        " Check the Vint version if we haven't checked it already.
        return 'vint --version'
    endif

    return ''
endfunction

function! ale_linters#vim#vint#GetCommand(buffer, version_output) abort
    let l:executable = ale_linters#vim#vint#GetExecutable(a:buffer)

    let l:warning_flag = ale#Var(a:buffer, 'vim_vint_show_style_issues') ? '-s' : '-w'

    if l:executable ==# 'docker'

        let l:can_use_no_color_flag = 1
    else

        if empty(s:vint_version) && !empty(a:version_output)
            " Parse the version out of the --version output.
            let s:vint_version = ale#semver#Parse(join(a:version_output, "\n"))
        endif

        let l:can_use_no_color_flag = empty(s:vint_version)
        \   || ale#semver#GreaterOrEqual(s:vint_version, [0, 3, 7])

    endif

    return 'vint '
    \   . l:warning_flag . ' '
    \   . (l:can_use_no_color_flag ? '--no-color ' : '')
    \   . s:enable_neovim
    \   . s:format
    \   . ' %t'
endfunction

function! ale_linters#vim#vint#GetExecutable(buffer) abort
    return ale#docker#GetBufExecutable(a:buffer, 'vim_vint', 'vint')
endfunction

call ale#linter#Define('vim', {
\   'name': 'vint',
\   'executable_callback': 'ale_linters#vim#vint#GetExecutable',
\   'command_chain': [
\       {'callback': 'ale_linters#vim#vint#VersionCommand', 'output_stream': 'stderr'},
\       {'callback': 'ale_linters#vim#vint#GetCommand', 'output_stream': 'stdout'},
\   ],
\   'docker_command_callback': 'ale_linters#vim#vint#GetCommand',
\   'output_stream': 'stdout',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
