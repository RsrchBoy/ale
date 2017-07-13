" Author: hauleth - https://github.com/hauleth

let s:linter = 'dockerfile_hadolint'

" always, yes, never
call ale#Set('dockerfile_hadolint_executable', 'hadolint')
call ale#Set('dockerfile_hadolint_use_docker', 'never')
call ale#Set('dockerfile_hadolint_docker_image', 'lukasmartinelli/hadolint')

function! ale_linters#dockerfile#hadolint#Handle(buffer, lines) abort
    " Matches patterns line the following:
    "
    " stdin:19: F: Pipe chain should start with a raw value.
    let l:pattern = '\v^/dev/stdin:?(\d+)? (\S+) (.+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:lnum = 0

        if l:match[1] !=# ''
            let l:lnum = l:match[1] + 0
        endif

        let l:type = 'W'
        let l:text = l:match[3]

        call add(l:output, {
        \   'lnum': l:lnum,
        \   'col': 0,
        \   'type': l:type,
        \   'text': l:text,
        \   'nr': l:match[2],
        \})
    endfor

    return l:output
endfunction

function! ale_linters#dockerfile#hadolint#GetCommand(buffer) abort
    let l:command = ale#docker#GetBufExec(a:buffer, s:linter)
    if l:command ==# 'docker'
        return 'docker run --rm -i ' . ale#Var(a:buffer, 'dockerfile_hadolint_docker_image')
    endif
    return 'hadolint -'
endfunction


call ale#linter#Define('dockerfile', {
\   'name': 'hadolint',
\   'executable_callback': { buffer -> ale#docker#GetBufExec(buffer, s:linter) },
\   'command_callback': 'ale_linters#dockerfile#hadolint#GetCommand',
\   'callback': 'ale_linters#dockerfile#hadolint#Handle',
\})
