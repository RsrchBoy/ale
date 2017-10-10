" Author: w0rp <devw0rp@gmail.com>
" Description: This file adds support for using the shellcheck linter with
"   shell scripts.

let s:linter = 'sh_shellcheck'

" This global variable can be set with a string of comma-separated error
" codes to exclude from shellcheck. For example:
"
" let g:ale_sh_shellcheck_exclusions = 'SC2002,SC2004'
let g:ale_sh_shellcheck_exclusions =
\   get(g:, 'ale_sh_shellcheck_exclusions', get(g:, 'ale_linters_sh_shellcheck_exclusions', ''))

call ale#linter#util#SetStandardVars(s:linter, 'shellcheck', 'rsrchboy/shellcheck:latest')

function! ale_linters#sh#shellcheck#GetDialectArgument(buffer) abort
    let l:shell_type = ale#handlers#sh#GetShellType(a:buffer)

    if !empty(l:shell_type)
        return l:shell_type
    endif

    " If there's no hashbang, try using Vim's buffer variables.
    if get(b:, 'is_bash')
        return 'bash'
    elseif get(b:, 'is_sh')
        return 'sh'
    elseif get(b:, 'is_kornshell')
        return 'ksh'
    endif

    return ''
endfunction

function! ale_linters#sh#shellcheck#GetCommand(buffer) abort
    let l:options = ale#Var(a:buffer, 'sh_shellcheck_options')
    let l:exclude_option = ale#Var(a:buffer, 'sh_shellcheck_exclusions')
    let l:dialect = ale_linters#sh#shellcheck#GetDialectArgument(a:buffer)

    " let l:command = ale#linter#util#GetCommand(buffer, s:linter)
    let l:command = ale#Escape(ale#Var(a:buffer, s:linter.'_executable')) . ' '
    \   . (!empty(l:options) ? ' ' . l:options : '')
    \   . (!empty(l:exclude_option) ? ' -e ' . l:exclude_option : '')
    \   . (!empty(l:dialect) ? ' -s ' . l:dialect : '')
    \   . ' -f gcc '
    if ale#linter#util#ShouldUseDocker(a:buffer, s:linter)
        return ale#docker#PrepareRunCmd(a:buffer, s:linter, l:command.' %s')
    endif
    return l:command . ' -'
endfunction

call ale#linter#Define('sh', {
\   'name':                'shellcheck',
\   'executable_callback': { buffer -> ale#linter#util#GetBufExec(buffer, s:linter) },
\   'command_callback':    'ale_linters#sh#shellcheck#GetCommand',
\   'callback':            'ale#handlers#gcc#HandleGCCFormat',
\   'output': 'both',
\})
