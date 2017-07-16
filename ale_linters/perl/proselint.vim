" Author: Chris Weyl <cweyl@alumni.drew.edu>
" Description: proselint for embedded POD

" So, this is our first docker-only (-native?) linter.
"
" We should probably make it easy to ditch the boilerplate.

let s:linter = 'perl_proselint'
call ale#Set('perl_proselint_executable', 'docker')
call ale#Set('perl_proselint_use_docker', 'always')
call ale#Set('perl_proselint_docker_image', 'rsrchboy/proselint-perl:latest')

call ale#linter#Define('perl', {
\   'name':             'proselint',
\   'executable':       'docker',
\   'command_callback': { buffer -> ale#docker#RunCmd(buffer, s:linter) },
\   'callback':         'ale#handlers#unix#HandleAsWarning',
\})
