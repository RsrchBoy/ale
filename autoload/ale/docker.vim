" Author: Chris Weyl <cweyl@alumni.drew.edu>

" In each of these functions, we may rely on the following linter-specific
" variables being set. (buffer-local honored)
"
"   g:ale_{linter}_use_docker       # always, never, yes
"   g:ale_{linter}_docker_image     # the linter's image
"   g:ale_{linter}_executable       # the non-docker executable name
"

" given a buffer, linter prefix (e.g. 'dockerfile_hadolint'), and the name of
" the specific command we would run, return whichever of the two (specific
" command or 'docker') we should be using
"
function! ale#docker#GetBufExecutable(buffer, linter, other_cmd) abort

    " if override says 'nope!' or we don't have an image defined,
    " then just return
    if !ale#Var(a:buffer, 'docker_allow') || !exists('g:ale_'.a:linter.'_docker_image')
        return a:other_cmd
    endif

    " check for mandatory directives
    let l:use_docker = ale#Var(a:buffer, a:linter.'_use_docker')
    if l:use_docker ==# 'never'
        return a:other_cmd
    elseif l:use_docker ==# 'always'
        return 'docker'
    endif

    " if we reach here, we want to use 'hadolint' if present...
    if executable(a:other_cmd)
        return a:other_cmd
    endif

    "... and 'docker' as a fallback.
    return 'docker'
endfunction

" transitional.
function! ale#docker#GetBufExec(buffer, linter) abort
    return ale#docker#GetBufExecutable(a:buffer, a:linter,
    \   ale#Var(a:buffer, a:linter.'_executable'))
endfunction


" ###########################################################


function! ale#docker#SetLinterVars(linter_fullname, image) abort
    call ale#Set(a:linter_fullname.'_use_docker', 'never')
    call ale#Set(a:linter_fullname.'_docker_image', a:image)
    return
endfunction


function! ale#docker#RunCmd(buffer, linter_fullname) abort
    return 'docker '
    \   . ale#Var(a:buffer, 'docker_run_cmd') . ' '
    \   . ale#Var(a:buffer, a:linter_fullname . '_docker_image')
endfunction


" Returns true if the indicated linter should run via docker for the given
" buffer
"
function! ale#docker#ShouldUseDocker(buffer, linter) abort

    " if override says 'nope!' or we don't have an image defined, then just
    " return
    if !ale#Var(a:buffer, 'docker_allow') || !exists('g:ale_'.a:linter.'_docker_image')
        return 0
    endif

    " check for mandatory directives
    let l:use_docker = ale#Var(a:buffer, a:linter.'_use_docker')
    if l:use_docker ==# 'never'
        return 0
    elseif l:use_docker ==# 'always'
        return 1
    endif

    let l:other_cmd = ale#Var(a:buffer, a:linter.'_executable')

    if executable(l:other_cmd)
        return 0
    endif

    "... and 'docker' as a fallback.
    return 1
endfunction
