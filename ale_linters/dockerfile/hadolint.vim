" Author: hauleth - https://github.com/hauleth

" always, yes, never
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

" This is a little different than the typical 'executable' callback.  We want
" to afford the user the chance to say always use docker, never use docker,
" and use docker if the hadolint executable is not present on the system.
"
" In the case of neither docker nor hadolint executables being present, it
" really doesn't matter which we return -- either will have the effect of
" 'nope, can't use this linter!'.

function! ale_linters#dockerfile#hadolint#GetExecutable(buffer) abort
    return ale#docker#GetBufExecutable(a:buffer, 'dockerfile_hadolint', 'hadolint')
endfunction

function! ale_linters#dockerfile#hadolint#GetCommand(buffer) abort
    let l:command = ale_linters#dockerfile#hadolint#GetExecutable(a:buffer)
    if l:command ==# 'docker'
        return 'docker run --rm -i ' . ale#Var(a:buffer, 'dockerfile_hadolint_docker_image')
    endif
    return 'hadolint -'
endfunction


call ale#linter#Define('dockerfile', {
\   'name': 'hadolint',
\   'executable_callback': 'ale_linters#dockerfile#hadolint#GetExecutable',
\   'command_callback': 'ale_linters#dockerfile#hadolint#GetCommand',
\   'callback': 'ale_linters#dockerfile#hadolint#Handle',
\})
