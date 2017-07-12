" Author: Chris Weyl <cweyl@alumni.drew.edu>
" Description: proselint for embedded POD

" So, this is our first docker-only (-native?) linter.
"
" We should probably make it easy to ditch the boilerplate.

call ale#Set('perl_proselint_executable', 'docker')
call ale#Set('perl_proselint_use_docker', 'always')
call ale#Set('perl_proselint_docker_image', 'rsrchboy/proselint-perl:latest')

function! ale_linters#perl#proselint#GetCommand(buffer) abort
    return ale#docker#RunCmd(a:buffer, 'perl_proselint')
endfunction

" \   'docker_native':    1,
" \   'docker_run_opts':  '',
" \   'command_callback': 'ale#docker#StdRunCmdCallback',
" \   'command_callback': 'ale_linters#perl#proselint#GetCommand',
call ale#linter#Define('perl', {
\   'name':             'proselint',
\   'executable':       'docker',
\   'command_callback': 'ale_linters#perl#proselint#GetCommand',
\   'callback':         'ale#handlers#unix#HandleAsWarning',
\})
