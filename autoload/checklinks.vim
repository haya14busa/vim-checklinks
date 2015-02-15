"=============================================================================
" FILE: autoload/checklinks.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('checklinks')
let s:HTTP = s:V.import('Web.HTTP')

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

if !exists('s:cache')
  let s:cache = {}
endif

" @return {'success': Boolean, 'status': Number}
function! s:check_url(url) abort
  if has_key(s:cache, a:url)
    return s:cache[a:url]
  endif
  try
    let r = s:HTTP.get(a:url)
  catch
    " Catch unexpected error e.g. s:HTTP.get('') throws E803: ID not found: 3
    let r = {'success': s:FALSE, 'status': -1}
  endtry
  let s:cache[a:url] = {'success': r.success, 'status': r.status}
  return s:cache[a:url]
endfunction

function! checklinks#check() abort
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
