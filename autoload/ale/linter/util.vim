" Author: Chris Weyl <cweyl@alumni.drew.edu>

" This is a collection of utility functions largely aimed at helping the
" linter choose between running a command natively and running the command via
" docker.

" In each of these functions, we may rely on the following linter-specific
" variables being set. (buffer-local honored)
"
"   g:ale_{linter}_use_docker       # always, never, yes
"   g:ale_{linter}_docker_image     # the linter's image
"   g:ale_{linter}_executable       # the non-docker executable name
"   g:ale_{linter}_options          # any options passed to the executable


" given a buffer, linter prefix (e.g. 'dockerfile_hadolint'), and the name of
" the specific command we would run, return whichever of the two (specific
" command or 'docker') we should be using
"
function! ale#linter#util#GetBufExec(buffer, linter) abort

    let l:other_cmd = ale#Var(a:buffer, a:linter.'_executable')

    " if override says 'nope!' or we don't have an image defined,
    " then just return
    if !ale#Var(a:buffer, 'docker_allow') || !exists('g:ale_'.a:linter.'_docker_image') || ale#Var(a:buffer, a:linter.'_docker_image') ==# ''
        return l:other_cmd
    endif

    " check for mandatory directives
    let l:use_docker = ale#Var(a:buffer, a:linter.'_use_docker')
    if l:use_docker ==# 'never'
        return l:other_cmd
    elseif l:use_docker ==# 'always'
        return 'docker'
    endif

    " if we reach here, we want to use 'hadolint' if present...
    if executable(l:other_cmd)
        return l:other_cmd
    endif

    "... and 'docker' as a fallback.
    return 'docker'
endfunction

" ###########################################################

" FIXME flesh this out...
function! ale#linter#util#SetStandardVars(linter, executable, image) abort
    call ale#Set(a:linter.'_use_docker', 'yes')
    call ale#Set(a:linter.'_docker_image', a:image)
    call ale#Set(a:linter.'_executable', a:executable)
    call ale#Set(a:linter.'_options', '')
    return
endfunction

" Returns true if the indicated linter should run via docker for the given
" buffer
"
function! ale#linter#util#ShouldUseDocker(buffer, linter) abort

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

function! ale#linter#util#GetCommand(buffer, linter_name) abort
    " let l:base_options = a:0 ? a:1 : '%t'
    let l:command = ale#Escape(ale#Var(a:buffer, a:linter_name.'_executable')) . ' '
    \  . ale#Var(a:buffer, a:linter_name.'_options')
    if ale#linter#util#ShouldUseDocker(a:buffer, a:linter_name)
        return ale#docker#PrepareRunCmd(a:buffer, a:linter_name, l:command.' %s')
    endif
    return l:command . ' %t'
endfunction

" function! ale#linter#util#Get
