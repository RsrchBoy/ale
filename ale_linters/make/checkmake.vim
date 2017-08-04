" Author: Chris Weyl <cweyl@alumni.drew.edu>

" FIXME we really ought to handle building options w/o

let s:linter = 'make_checkmake'
call ale#Set(s:linter.'_options', '--format="-:{{.LineNumber}}:[{{.Rule}}] {{.Violation}}"')
call ale#linter#util#SetStandardVars(s:linter, 'checkmake', '')

call ale#linter#Define('make', {
\   'name': 'checkmake',
\   'executable_callback': { buffer -> ale#linter#util#GetBufExec(buffer, s:linter) },
\   'command_callback':    { buffer -> ale#linter#util#GetCommand(buffer, s:linter) },
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\})
