" Author: Daniel M. Capella https://github.com/polyzen, Chris Weyl <cweyl@alumni.drew.edu>
" Description: proselint for Vim help files

let s:linter = 'help_proselint'

call ale#Set('help_proselint_executable',   'proselint')
call ale#Set('help_proselint_use_docker',   'never')
call ale#Set('help_proselint_docker_image', 'rsrchboy/proselint:latest')

function! ale_linters#help#proselint#GetCommand(buffer) abort
    if ale#docker#ShouldUseDocker(a:buffer, s:linter)
        return ale#docker#RunCmd(a:buffer, s:linter)
    endif
    return ale#Var(a:buffer, s:linter.'_executable') . ' %t'
endfunction

call ale#linter#Define('help', {
\   'name':                'proselint',
\   'executable_callback': { buffer -> ale#docker#GetBufExec(buffer, s:linter) },
\   'command_callback':    'ale_linters#help#proselint#GetCommand',
\   'callback':            'ale#handlers#unix#HandleAsWarning',
\})
