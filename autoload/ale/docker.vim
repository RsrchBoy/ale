" Author: Chris Weyl <cweyl@alumni.drew.edu>

" given a buffer, linter prefix (e.g. 'dockerfile_hadolint'), and the name of
" the specific command we would run, return whichever of the two (specific
" command or 'docker') we should be using
function! ale#docker#GetBufExecutable(buffer, linter, other_cmd) abort

    " if override says 'nope!' then just return
    if !ale#Var(a:buffer, 'docker_allow')
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

function! ale#docker#RunCmd(buffer, image) abort
    return 'docker ' . ale#Var(a:buffer, 'docker_run_cmd') . a:image
endfunction
