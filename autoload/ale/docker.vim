" Author: Chris Weyl <cweyl@alumni.drew.edu>

" In each of these functions, we may rely on the following linter-specific
" variables being set. (buffer-local honored)
"
"   g:ale_{linter}_use_docker       # always, never, yes
"   g:ale_{linter}_docker_image     # the linter's image
"   g:ale_{linter}_executable       # the non-docker executable name
"

function! ale#docker#RunCmd(buffer, linter_fullname) abort
    return 'docker '
    \   . ale#Var(a:buffer, 'docker_run_cmd') . ' '
    \   . ale#Var(a:buffer, a:linter_fullname . '_docker_image')
endfunction

function! ale#docker#PrepareRunCmd(buffer, linter_fullname, command) abort

    " Ensure the file is appropriately accessible.
    let l:volumes = a:command =~# '%t' ? ' -v %t:%t:ro ' : ''

    return 'docker '
    \   . ale#Var(a:buffer, 'docker_run_cmd') . ' --entrypoint="" '
    \   . l:volumes
    \   . ale#Var(a:buffer, a:linter_fullname.'_docker_image') . ' '
    \   . a:command
endfunction

function! ale#docker#StdRunCmdCallback(buffer, linter) abort
    return ale#docker#RunCmd(a:buffer,
    \   getbufvar(a:buffer, 'ale_original_filetype').'_'.a:linter.name)
endfunction

" transitional.
function! ale#docker#GetBufExec(buffer, linter) abort
    return ale#linter#util#GetBufExec(a:buffer, a:linter)
endfunction

" transitional.
function! ale#docker#GetCommand(buffer, linter_name) abort
    return ale#linter#util#GetCommand(a:buffer, a:linter_name)
endfunction
