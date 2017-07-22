" Just sleep -- so as to force a stop/kill

let s:linter = 'ale_test_ft_sleep'
call ale#Set(s:linter.'_use_docker', 'always')
call ale#Set(s:linter.'_options', "-c 'sleep 5m'; echo ")
call ale#linter#util#SetStandardVars(s:linter, '/bin/sh', 'ubuntu:xenial')

call ale#linter#Define('ale_test_ft', {
\   'name':                'sleep',
\   'executable_callback': { buffer -> ale#linter#util#GetBufExec(buffer, s:linter) },
\   'command_callback':    { buffer -> ale#linter#util#GetCommand(buffer, s:linter) },
\   'callback':            'ale#handlers#unix#HandleAsWarning',
\})
