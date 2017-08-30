" Author: Chris Weyl <cweyl@alumni.drew.edu>

" In each of these functions, we may rely on the following linter-specific
" variables being set. (buffer-local honored)
"
"   g:ale_{ft}_{name}_use_docker       # always, never, yes
"   g:ale_{ft}_{name}_docker_image     # the linter's image
"   g:ale_{ft}_{name}_executable       # the non-docker executable name
"   g:ale_{ft}_{name}_options          # any options passed to the executable

" Deprecated: true
function! ale#docker#RunCmd(buffer, linter_fullname) abort
    return 'docker '
    \   . ale#Var(a:buffer, 'docker_run_cmd') . ' '
    \   . ale#Var(a:buffer, a:linter_fullname . '_docker_image')
endfunction

" Kill all containers we've launched
function! ale#docker#KillAllJobs()
    silent! call system("/bin/sh -c 'docker ps --filter label=ale.vim.pid=" . getpid() . " | xargs docker rm --force'")
endfunction

" Returns a list of all images -- global, and only those loaded at the moment.
function! ale#docker#GetAllImages()
    let l:globals = filter(keys(g:), { i, v -> v =~ '\v^ale_.+_docker_image$' })
    return filter(uniq(sort(map(l:globals, { k, v -> get(g:, v) }))), { k, v -> v !=# '' })
endfunction

function! ale#docker#KillJob(job) abort
    " echom 'in s:KillContainer() for run_id: '.a:job.run_id

    let l:command
    \   = 'docker ps'
    \   .   ' --filter label=ale.linter.run_id=' . a:job.run_id
    \   .   ' --filter status=running'
    \   .   ' --format ''{{.ID}}'' '

    let l:command = 'docker kill `'.l:command.'`'

    " echom 'Killing off old container with: ' . l:command
    let l:command = ale#job#PrepareCommand(l:command)

    let l:job_options = {
    \   'mode': 'nl',
    \   'exit_cb': { job_id, exit -> ale#job#HandleExit(job_id, exit, a:job.buffer) },
    \   'in_container': 0,
    \   'buffer': a:job.buffer
    \}

    let l:job_id = ale#job#Start(l:command, l:job_options)

    " echom '...returned id: ' . l:job_id
    return l:job_id
endfunction

function! ale#docker#PrepareRunCmd(buffer, linter_fullname, command) abort

    " this could be smarter, but WFN
    let l:root = ale#Escape(ale#path#ProjectRoot(a:buffer))

    " Ensure the project and our temporary file is appropriately accessible.
    let l:volumes  = ' -v '.l:root.':'.l:root.':ro '
    let l:volumes .= ' -v %t:%s:ro '

    let l:labels
    \   = ' --label ale.vim.pid=' . getpid() . ' '
    \   . ' --label ale.linter.run_id=%i '
    \   . ' --label ale.linter.buffer=' . a:buffer . ' '
    \   . ' --label ale.linter.linter=' . a:linter_fullname . ' '

    return 'docker '
    \   . '--network=none '
    \   . ale#Var(a:buffer, 'docker_run_cmd') . ' --entrypoint="" '
    \   . ' --workdir=' . l:root
    \   . l:labels
    \   . l:volumes
    \   . ale#Var(a:buffer, a:linter_fullname.'_docker_image') . ' '
    \   . a:command
endfunction
