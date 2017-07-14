" Author: Chris Weyl <cweyl@alumni.drew.edu>
" Description: Helper functions for proselint filters

" What: define a standard proselint linter via one function
function! ale#proselint#Define(filetype) abort

    call ale#Set(a:filetype.'_proselint_executable',   'proselint')
    call ale#Set(a:filetype.'_proselint_use_docker',   'never')
    call ale#Set(a:filetype.'_proselint_docker_image', 'rsrchboy/proselint:latest')

    call ale#linter#Define(a:filetype, {
    \   'name':                'proselint',
    \   'executable_callback': { buffer -> ale#docker#GetBufExec(buffer, a:filetype.'_proselint') },
    \   'command_callback':    { buffer -> ale#docker#GetCommand(buffer, a:filetype.'_proselint') },
    \   'callback':            'ale#handlers#unix#HandleAsWarning',
    \})
endfunction
