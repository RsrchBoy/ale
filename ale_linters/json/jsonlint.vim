" Author: KabbAmine <amine.kabb@gmail.com>

let s:linter = 'json_jsonlint'
call ale#Set(s:linter.'_options', '--compact')
call ale#linter#util#SetStandardVars(s:linter, 'jsonlint', 'papakpmartin/jsonlint:latest')

function! ale_linters#json#jsonlint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    " line 2, col 15, found: 'STRING' - expected: 'EOF', '}', ',', ']'.

    let l:pattern = '^line \(\d\+\), col \(\d*\), \(.\+\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[3],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('json', {
\   'name':                'jsonlint',
\   'output_stream':       'stderr',
\   'executable_callback': { buffer -> ale#linter#util#GetBufExec(buffer, s:linter) },
\   'command_callback':    { buffer -> ale#linter#util#GetCommand(buffer, s:linter) },
\   'callback':            'ale_linters#json#jsonlint#Handle',
\})
