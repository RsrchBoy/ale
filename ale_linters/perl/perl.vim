" Author: Vincent Lequertier <https://github.com/SkySymbol>
" Description: This file adds support for checking perl syntax

let s:linter = 'perl_perl'

" FIXME need to bind-mount lib/ also
call ale#Set('perl_perl_options', '-c -Mwarnings -Ilib')
call ale#linter#util#SetStandardVars(s:linter, 'perl', 'lintersofdoom/perl:latest')

let s:begin_failed_skip_pattern = '\v' . join([
\   '^Compilation failed in require',
\   '^Can''t locate',
\], '|')

function! ale_linters#perl#perl#Handle(buffer, lines) abort
    let l:pattern = '\(.\+\) at \(.\+\) line \(\d\+\)'
    let l:output = []
    let l:basename = expand('#' . a:buffer . ':t')

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:line = l:match[3]
        let l:text = l:match[1]
        let l:type = 'E'

        if ale#path#IsBufferPath(a:buffer, l:match[2])
        \ && (
        \   l:text isnot# 'BEGIN failed--compilation aborted'
        \   || empty(l:output)
        \   || match(l:output[-1].text, s:begin_failed_skip_pattern) < 0
        \ )
            call add(l:output, {
            \   'lnum': l:line,
            \   'text': l:text,
            \   'type': l:type,
            \})
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('perl', {
\   'name':                'perl',
\   'executable_callback': { buffer -> ale#linter#util#GetBufExec(buffer, s:linter) },
\   'command_callback':    { buffer -> ale#linter#util#GetCommand(buffer, s:linter) },
\   'output_stream':       'both',
\   'callback':            'ale_linters#perl#perl#Handle',
\})
