" Author: Chris Weyl <cweyl@alumni.drew.edu>
" Description: proselint for mail files

let s:linter = 'mail_proselint'

call ale#Set('mail_proselint_executable',   'proselint')
call ale#Set('mail_proselint_use_docker',   'never')
call ale#Set('mail_proselint_docker_image', 'rsrchboy/proselint:latest')

call ale#linter#Define('mail', {
\   'name':                'proselint',
\   'executable_callback': { buffer -> ale#docker#GetBufExec(buffer, s:linter) },
\   'command_callback':    { buffer -> ale#docker#GetCommand(buffer, s:linter) },
\   'callback':            'ale#handlers#unix#HandleAsWarning',
\})
