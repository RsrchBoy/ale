" Author: Chris Weyl <cweyl@alumni.drew.edu>
" Description: proselint for mail files

let s:linter_name = 'mail_proselint'

call ale#Set('mail_proselint_executable',   'proselint')
call ale#Set('mail_proselint_use_docker',   'never')
call ale#Set('mail_proselint_docker_image', 'rsrchboy/proselint:latest')

function! ale_linters#mail#proselint#GetCommand(buffer) abort
    if ale#docker#ShouldUseDocker(a:buffer, s:linter_name)
        return ale#docker#RunCmd(a:buffer, s:linter_name)
    endif
    return ale#Var(a:buffer, s:linter_name.'_executable') . ' %t'
endfunction

function! ale_linters#mail#proselint#GetExecutable(buffer) abort
    return ale#docker#GetBufExec(a:buffer, s:linter_name)
endfunction

call ale#linter#Define('mail', {
\   'name':                'proselint',
\   'executable_callback': 'ale_linters#mail#proselint#GetExecutable',
\   'command_callback':    'ale_linters#mail#proselint#GetCommand',
\   'callback':            'ale#handlers#unix#HandleAsWarning',
\})
