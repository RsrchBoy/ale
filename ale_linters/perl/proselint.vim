" Author: Chris Weyl <cweyl@alumni.drew.edu>
" Description: proselint for embedded POD

" So, this is our first docker-only (-native?) linter.
"
" We should probably make it easy to ditch the boilerplate.

" FIXME for now
finish

let s:linter = 'perl_proselint'
call ale#Set(s:linter.'_use_docker', 'always')
call ale#linter#util#SetStandardVars(s:linter, 'docker', 'rsrchboy/proselint-perl:latest')

call ale#linter#Define('perl', {
\   'name':             'proselint',
\   'executable':       'docker',
\   'command_callback': { buffer -> ale#linter#util#GetCommand(buffer, s:linter) },
\   'callback':         'ale#handlers#unix#HandleAsWarning',
\})
