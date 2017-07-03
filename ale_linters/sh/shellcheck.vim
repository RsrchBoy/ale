" Author: w0rp <devw0rp@gmail.com>
" Description: This file adds support for using the shellcheck linter with
"   shell scripts.

" This global variable can be set with a string of comma-seperated error
" codes to exclude from shellcheck. For example:
"
" let g:ale_sh_shellcheck_exclusions = 'SC2002,SC2004'
let g:ale_sh_shellcheck_exclusions =
\   get(g:, 'ale_sh_shellcheck_exclusions', get(g:, 'ale_linters_sh_shellcheck_exclusions', ''))

let g:ale_sh_shellcheck_executable =
\   get(g:, 'ale_sh_shellcheck_executable', 'shellcheck')

let g:ale_sh_shellcheck_options =
\   get(g:, 'ale_sh_shellcheck_options', '')

" always, yes, never
call ale#Set('sh_shellcheck_use_docker', 'never')
call ale#Set('sh_shellcheck_docker_image', 'rsrchboy/shellcheck:latest')

function! ale_linters#sh#shellcheck#GetExecutable(buffer) abort
    return ale#docker#GetBufExecutable(a:buffer, 'sh_shellcheck',
    \   ale#Var(a:buffer, 'sh_shellcheck_executable'))
endfunction

" FIXME TODO we're going to have to address making this more... coherent.
"
" Perhaps...
"
" * ale#docker#RunCmd() can be extended to craft the 'docker run ... image'
" part w/o requiring any additional lookups
" * ...

function! ale_linters#sh#shellcheck#GetDockerCommand(buffer) abort
    let l:exclude_option = ale#Var(a:buffer, 'sh_shellcheck_exclusions')

    return ale_linters#sh#shellcheck#GetExecutable(a:buffer)
    \   . ale#Var(a:buffer, 'docker_run_cmd') . ale#Var(a:buffer, 'sh_shellcheck_docker_image')
    \   . ' ' . ale#Var(a:buffer, 'sh_shellcheck_options')
    \   . ' ' . (!empty(l:exclude_option) ? '-e ' . l:exclude_option : '')
    \   . ' ' . s:GetDialectArgument() . ' -f gcc -'
endfunction

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

    return ale_linters#sh#shellcheck#GetExecutable(a:buffer)
    \   . ' ' . ale#Var(a:buffer, 'sh_shellcheck_options')
    \   . ' ' . (!empty(l:exclude_option) ? '-e ' . l:exclude_option : '')
    \   . ' ' . s:GetDialectArgument() . ' -f gcc -'
endfunction

call ale#linter#Define('sh', {
\   'name': 'shellcheck',
\   'executable_callback': 'ale_linters#sh#shellcheck#GetExecutable',
\   'command_callback': 'ale_linters#sh#shellcheck#GetCommand',
\   'docker_command_callback': 'ale_linters#sh#shellcheck#GetDockerCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
