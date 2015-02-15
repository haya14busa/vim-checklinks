"=============================================================================
" FILE: autoload/checklinks.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:TRUE = !0
let s:FALSE = 0

let s:V = vital#of('checklinks')
let s:String = s:V.import('Data.String')
let s:List = s:V.import('Data.List')
let s:HTTP = s:V.import('Web.HTTP')

function! s:init_hl() abort
  hi CheckLinksUnderline term=underline cterm=underline gui=underline
endfunction
call s:init_hl()
augroup plugin-checklinks-highlight
  autocmd!
  autocmd ColorScheme * call s:init_hl()
augroup END

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

let g:checklinks#highlights = get(g:, 'checklinks#highlights',
\ {
\   'ok': 'CheckLinksUnderline',
\   'bad': 'Error'
\ }
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

" @return links: List[String]
function! s:scanlinks(text) abort
  return s:List.uniq(s:String.scan(a:text, g:checklinks#pattern))
endfunction

function! s:gettext() abort
  return join(getline(1, '$'), "\n")
endfunction

function! s:noregex(pattern) abort
  return '\V' . escape(a:pattern, '\')
endfunction

if !exists('s:hi')
  let s:hi = { 'ids': [] }
endif

function! s:hi.matchadd(...) abort
  let self.ids += [call('matchadd', a:000)]
endfunction

function! s:hi.matchdeleteall() abort
  for id in self.ids
    call matchdelete(id)
  endfor
  let self.ids = []
endfunction

function! checklinks#check() abort
  for link in s:List.sort(s:scanlinks(s:gettext()), 'len(a:a)-len(a:b)')
    let r = s:check_url(link)
    if r.success
      call s:hi.matchadd(g:checklinks#highlights.ok, s:noregex(link))
    else
      call s:hi.matchadd(g:checklinks#highlights.bad, s:noregex(link))
    endif
  endfor
endfunction

function! checklinks#off() abort
  call s:hi.matchdeleteall()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
