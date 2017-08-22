" Author: chew-z https://github.com/chew-z
" Description: vale for Markdown files

let s:linter = 'markdown_vale'
call ale#Set(s:linter.'_options', '--output=line')
call ale#linter#util#SetStandardVars(s:linter, 'vale', 'rsrchboy/vale:latest')

call ale#linter#Define('markdown', {
\   'name':                'vale',
\   'executable_callback': { buffer -> ale#linter#util#GetBufExec(buffer, s:linter) },
\   'command_callback':    { buffer -> ale#linter#util#GetCommand(buffer, s:linter) },
\   'callback':            'ale#handlers#unix#HandleAsWarning',
\})
