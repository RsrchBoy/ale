" Author: Chris Weyl <cweyl@alumni.drew.edu>

" In each of these functions, we may rely on the following linter-specific
" variables being set. (buffer-local honored)
"
"   g:ale_{ft}_{name}_use_docker       # always, never, yes
"   g:ale_{ft}_{name}_docker_image     # the linter's image
"   g:ale_{ft}_{name}_executable       # the non-docker executable name
"   g:ale_{ft}_{name}_options          # any options passed to the executable

" Deprecated: true
function! ale#docker#RunCmd(buffer, linter_fullname) abort
    return 'docker '
    \   . ale#Var(a:buffer, 'docker_run_cmd') . ' '
    \   . ale#Var(a:buffer, a:linter_fullname . '_docker_image')
endfunction

" Returns a list of all images -- global, and only those loaded at the moment.
function! ale#docker#GetAllImages()
    let l:globals = filter(keys(g:), { i, v -> v =~ '\v^ale_.+_docker_image$' })
    return filter(uniq(sort(map(l:globals, { k, v -> get(g:, v) }))), { k, v -> v !=# '' })
endfunction

function! ale#docker#PrepareRunCmd(buffer, linter_fullname, command) abort

    " Ensure the file is appropriately accessible.
    let l:volumes = a:command =~# '%t' ? ' -v %t:%t:ro ' : ''

    let l:labels
    \   = ' --label w0rp.ale.linter.run_id=%i '
    \   . ' --label w0rp.ale.linter.vim.pid=' . getpid() . ' '
    \   . ' --label w0rp.ale.linter.buffer=' . a:buffer . ' '
    \   . ' --label w0rp.ale.linter.linter=' . a:linter_fullname . ' '

    return 'docker '
    \   . ale#Var(a:buffer, 'docker_run_cmd') . ' --entrypoint="" '
    \   . l:labels
    \   . l:volumes
    \   . ale#Var(a:buffer, a:linter_fullname.'_docker_image') . ' '
    \   . a:command
endfunction
