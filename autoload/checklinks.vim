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
let s:Reunions = s:V.import('Reunions')

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

function! s:getlinks() abort
  return s:List.sort(s:scanlinks(s:gettext()), 'len(a:a)-len(a:b)')
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

" r: {'success': Boolean, 'status': Number}
function! s:hilink(link, r) abort
  if a:r.success
    call s:hi.matchadd(g:checklinks#highlights.ok, s:noregex(a:link))
  else
    call s:hi.matchadd(g:checklinks#highlights.bad, s:noregex(a:link))
  endif
endfunction

function! checklinks#check() abort
  for link in s:getlinks()
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

function! checklinks#checkasync() abort
  for link in s:getlinks()
    call s:spawn(link)
  endfor
endfunction

function! s:spawn(link) abort
  let m = {}
  let m.process = s:makeprocess(a:link)
  function! m.apply(parent) abort
    if self.process.is_exit()
      return a:parent.kill(self)
    endif
  endfunction
  call s:Reunions.register(m)
endfunction

function! s:makeprocess(link) abort
  let process = s:Reunions.http_get(a:link)
  let process.link = a:link
  function! process.then(output, ...) abort
    " echom PP(a:output)
    " call Plog(PP(a:output))
    echom 'then'
    call s:hilink(self.link, {'success': output.success, 'status': output.status})
  endfunction
  return process
endfunction

augroup reunions-checklinks
  autocmd!
  autocmd CursorHold * call s:Reunions.update_in_cursorhold(1)
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
