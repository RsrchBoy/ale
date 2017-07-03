" Author: Adriaan Zonnenberg <amz@adriaan.xyz>
" Description: sqlint for SQL files

" always, yes, never
call ale#Set('sql_sqlint_use_docker', 'never')
call ale#Set('sql_sqlint_docker_image', 'rsrchboy/sqlint:latest')

function! ale_linters#sql#sqlint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    "
    " stdin:3:1:ERROR syntax error at or near "WIBBLE"
    let l:pattern = '\v^[^:]+:(\d+):(\d+):(\u+) (.*)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'type': l:match[3][0],
        \   'text': l:match[4],
        \})
    endfor

    return l:output
endfunction

function! ale_linters#sql#sqlint#GetExecutable(buffer) abort
    return ale#docker#GetBufExecutable(a:buffer, 'sql_sqlint', 'sqlint')
endfunction

function! ale_linters#sql#sqlint#GetDockerCommand(buffer) abort
    return ale_linters#sql#sqlint#GetExecutable(a:buffer)
    \ . ale#Var(a:buffer, 'docker_run_cmd') . ale#Var(a:buffer, 'sql_sqlint_docker_image')
endfunction

call ale#linter#Define('sql', {
\   'name': 'sqlint',
\   'executable_callback': 'ale_linters#sql#sqlint#GetExecutable',
\   'command': 'sqlint',
\   'docker_command_callback': 'ale_linters#sql#sqlint#GetDockerCommand',
\   'callback': 'ale_linters#sql#sqlint#Handle',
\})
