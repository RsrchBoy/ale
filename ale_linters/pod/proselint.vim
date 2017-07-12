" Author: Daniel M. Capella https://github.com/polyzen
" Description: proselint for Pod files

" " always, yes, never
" call ale#Set('dockerfile_hadolint_executable', 'hadolint')
" call ale#Set('dockerfile_hadolint_use_docker', 'never')
" call ale#Set('dockerfile_hadolint_docker_image', 'lukasmartinelli/hadolint')

call ale#linter#Define('pod', {
\   'name': 'proselint',
\   'executable': 'proselint',
\   'command': 'proselint %t',
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\})
