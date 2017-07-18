" Author: neersighted <bjorn@neersighted.com>
" Description: golint for Go files

let s:linter = 'go_golint'
call ale#linter#util#SetStandardVars(s:linter, 'golint', '')

call ale#linter#Define('go', {
\   'name': 'golint',
\   'executable_callback': { buffer -> ale#linter#util#GetBufExec(buffer, s:linter) },
\   'command_callback':    { buffer -> ale#linter#util#GetCommand(buffer, s:linter) },
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\})
