"=============================================================================
" FILE: autoload/checklinks.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

""Author: itchyny
" License: MIT License
" https://github.com/itchyny/vim-highlighturl/blob/51f53e10f31daae20173fa7536d579925b93ad68/autoload/highlighturl.vim#L19-L26
" this regular expression is taken from itchny's code in vim-highlighturl and
" little modified.
let g:checklinks#pattern = get(g:, 'checklinks#pattern',
\ '\m\c\%(\%(h\?ttps\?\):\/\/\|[a-z]\+@[a-z]\+.[a-z]\+:\)\%('
\.'\%([&:#*@~%_\-=?!+;/.0-9A-Za-z]*\%([.,][&:#*@~%_\-=?!+;/0-9A-Za-z]\+\)\+\)\?'
\.'\%(([&:#*@~%_\-=?!+;/.0-9A-Za-z]*)\)\?'
\.'\%({\%([&:#*@~%_\-=?!+;/.0-9A-Za-z]*\|{[&:#*@~%_\-=?!+;/.0-9A-Za-z]*}\)}\)\?'
\.'\%(\[[&:#*@~%_\-=?!+;/.0-9A-Za-z]*\]\)\?'
\.'\)*[-/0-9A-Za-z]*\%(:\d\d*\/\?\)\?'
\)

function! checklinks#check() abort
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
