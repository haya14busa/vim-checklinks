"=============================================================================
" FILE: plugin/checklinks.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
if expand('%:p') ==# expand('<sfile>:p')
  unlet! g:loaded_checklinks
endif
if exists('g:loaded_checklinks')
  finish
endif
let g:loaded_checklinks = 1
let s:save_cpo = &cpo
set cpo&vim

command! CheckLinks    call checklinks#check()
command! CheckLinksOff call checklinks#off()

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
