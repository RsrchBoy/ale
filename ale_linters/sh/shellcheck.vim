" Author: w0rp <devw0rp@gmail.com>
" Description: This file adds support for using the shellcheck linter with
"   shell scripts.

let s:linter = 'sh_shellcheck'

" This global variable can be set with a string of comma-seperated error
" codes to exclude from shellcheck. For example:
"
" let g:ale_sh_shellcheck_exclusions = 'SC2002,SC2004'
let g:ale_sh_shellcheck_exclusions =
\   get(g:, 'ale_sh_shellcheck_exclusions', get(g:, 'ale_linters_sh_shellcheck_exclusions', ''))

call ale#linter#util#SetStandardVars(s:linter, 'shellcheck', 'rsrchboy/shellcheck:latest')

function! s:GetDialectArgument() abort
    if exists('b:is_bash') && b:is_bash
        return '-s bash'
    elseif exists('b:is_sh') && b:is_sh
        return '-s sh'
    elseif exists('b:is_kornshell') && b:is_kornshell
        return '-s ksh'
    endif

    return ''
endfunction

function! ale_linters#sh#shellcheck#GetCommand(buffer) abort
    let l:exclude_option = ale#Var(a:buffer, 'sh_shellcheck_exclusions')

    " let l:command = ale#linter#util#GetCommand(buffer, s:linter)
    let l:command = ale#Escape(ale#Var(a:buffer, s:linter.'_executable')) . ' '
    \  . ale#Var(a:buffer, s:linter.'_options') . ' '
    \  . (!empty(l:exclude_option) ? '-e ' . l:exclude_option : '') . ' '
    \  . s:GetDialectArgument() . ' -f gcc '
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
\})
