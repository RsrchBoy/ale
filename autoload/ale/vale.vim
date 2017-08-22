
" What: define a standard vale linter via one function
function! ale#vale#Define(filetype) abort
    let l:linter = a:filetype.'_vale'
    call ale#Set(l:linter.'_options', '--output=line')
    call ale#linter#util#SetStandardVars(l:linter, 'vale', 'rsrchboy/vale:latest')

    call ale#linter#Define(a:filetype, {
    \   'name':                'vale',
    \   'executable_callback': { buffer -> ale#linter#util#GetBufExec(buffer, l:linter) },
    \   'command_callback':    { buffer -> ale#linter#util#GetCommand(buffer, l:linter) },
    \   'callback':            'ale#handlers#unix#HandleAsWarning',
    \})
endfunction
