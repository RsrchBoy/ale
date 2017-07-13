" Author: Daniel M. Capella https://github.com/polyzen, Chris Weyl <cweyl@alumni.drew.edu>
" Description: proselint for Vim help files

let s:linter = 'help_proselint'

call ale#Set('help_proselint_executable',   'proselint')
call ale#Set('help_proselint_use_docker',   'never')
call ale#Set('help_proselint_docker_image', 'rsrchboy/proselint:latest')

call ale#linter#Define('help', {
\   'name':                'proselint',
\   'executable_callback': { buffer -> ale#docker#GetBufExec(buffer, s:linter) },
\   'command_callback':    { buffer -> ale#docker#GetCommand(buffer, s:linter) },
\   'callback':            'ale#handlers#unix#HandleAsWarning',
\})
