" Author: Sol Bekic https://github.com/s-ol
" Description: luacheck linter for lua files

let s:linter = 'lua_luacheck'

call ale#linter#util#SetStandardVars(s:linter, 'luacheck', '')

function! ale_linters#lua#luacheck#GetCommand(buffer) abort
    return ale#Escape(ale_linters#lua#luacheck#GetExecutable(a:buffer))
    \   . ' ' . ale#Var(a:buffer, 'lua_luacheck_options')
    \   . ' --formatter plain --codes --filename %s -'
endfunction

function! ale_linters#lua#luacheck#Handle(buffer, lines) abort
    " Matches patterns line the following:
    "
    " artal.lua:159:17: (W111) shadowing definition of loop variable 'i' on line 106
    " artal.lua:182:7: (W213) unused loop variable 'i'
    let l:pattern = '^.*:\(\d\+\):\(\d\+\): (\([WE]\)\(\d\+\)) \(.\+\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[3] . l:match[4] . ': ' . l:match[5],
        \   'type': l:match[3],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('lua', {
\   'name': 'luacheck',
\   'executable_callback': { buffer -> ale#Var(buffer, s:linter.'_executable') },
\   'command_callback': 'ale_linters#lua#luacheck#GetCommand',
\   'callback': 'ale_linters#lua#luacheck#Handle',
\})
