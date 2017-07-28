" Author: KabbAmine <amine.kabb@gmail.com>

let s:linter = 'yaml_yamllint'
call ale#Set(s:linter.'_options', '-f parsable')
call ale#linter#util#SetStandardVars(s:linter, 'yamllint', 'lintersofdoom/yamllint:latest')

function! ale_linters#yaml#yamllint#Handle(buffer, lines) abort
    " Matches patterns line the following:
    " something.yaml:1:1: [warning] missing document start "---" (document-start)
    " something.yml:2:1: [error] syntax error: expected the node content, but found '<stream end>'
    let l:pattern = '^.*:\(\d\+\):\(\d\+\): \[\(error\|warning\)\] \(.\+\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:line = l:match[1] + 0
        let l:col = l:match[2] + 0
        let l:type = l:match[3]
        let l:text = l:match[4]

        call add(l:output, {
        \   'lnum': l:line,
        \   'col': l:col,
        \   'text': l:text,
        \   'type': l:type ==# 'error' ? 'E' : 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('yaml', {
\   'name': 'yamllint',
\   'executable_callback': { buffer -> ale#linter#util#GetBufExec(buffer, s:linter) },
\   'command_callback':    { buffer -> ale#linter#util#GetCommand(buffer, s:linter) },
\   'callback': 'ale_linters#yaml#yamllint#Handle',
\})
