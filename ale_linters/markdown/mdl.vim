" Author: Steve Dignam <steve@dignam.xyz>
" Description: Support for mdl, a markdown linter

let s:linter = 'markdown_mdl'
call ale#linter#util#SetStandardVars(s:linter, 'mdl', 'rsrchboy/mdl:latest')

function! ale_linters#markdown#mdl#Handle(buffer, lines) abort
    " matches: '(stdin):173: MD004 Unordered list style'
    let l:pattern = ':\(\d*\): \(.*\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'text': l:match[2],
        \   'type': 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('markdown', {
\   'name':                'mdl',
\   'executable_callback': { buffer -> ale#linter#util#GetBufExec(buffer, s:linter) },
\   'command_callback':    { buffer -> ale#linter#util#GetCommand(buffer, s:linter) },
\   'callback':            'ale_linters#markdown#mdl#Handle'
\})
