" ============================================================================
" File:        vim-sourcegraph.vim
" Description: Vim wrapper for srclib
" Author:      Chih-Wei Chang (Bert) <jrweizhang AT gmail.com>
" Licence:     Vim licence
" Website:     http://github.com/lazywei/vim-sourcegraph
" Version:     0.0.1
" Note:        WIP
" ============================================================================
" TODO Fix --no lines in buffer-- error when we close then reopen window
" TODO cache results and don't analyze if we don't need to

scriptencoding utf-8

if !has('python')
  echo "Error: Required vim compiled with +python"
  finish
endif

let s:debug = 0
let s:debug_file = 'vim-sourcegraph.log'

let s:BufferName = 'Sourcegraph'
let s:path = expand('<sfile>:p:h')

command! -nargs=0 SrcDescribe call s:SrcDescribe()
command! -nargs=0 SrcClose call s:SrcClose()

map <unique> <Leader>s :SrcDescribe<cr>
map <unique> <Leader>q :SrcClose<cr>


function! s:SrcDescribe()
  let current_buffer = expand('%:p')
  let start_byte = line2byte(line("."))+col(".") - 1
  let description = system('src api describe --file ' . current_buffer . ' --start-byte ' . start_byte)

  call s:OpenWindow('')
  call s:UpdateWindow(description)
endfunction

" Window management {{{1
" s:ToggleWindow() {{{2
function! s:ToggleWindow() abort
    call s:debug('ToggleWindow called')

    let srclibwinnr = bufwinnr(s:BufferName)
    if srclibwinnr != -1
        call s:SrcClose()
        return
    endif

    call s:OpenWindow('')

    call s:debug('ToggleWindow finished')
endfunction

" s:OpenWindow() {{{2
function! s:OpenWindow(flags) abort
    call s:debug("OpenWindow called with flags: '" . a:flags . "'")

    " Return if the tagbar window is already open
    let srclibwinnr = bufwinnr(s:BufferName)
    if srclibwinnr != -1
        call s:debug("OpenWindow finished, srclib already open")
        return
    endif

    let s:window_opening = 1
    let openpos = 'botright vertical '
    let srclib_width = 300
    exe 'silent ' . openpos . 'split ' . s:BufferName
    unlet s:window_opening

    call s:InitWindow()

    call s:GotoWin('p')

    call s:debug('OpenWindow finished')
endfunction

" s:InitWindow() {{{2
function! s:InitWindow() abort
    call s:debug('InitWindow called')

    setlocal filetype=srclib

    setlocal noreadonly " in case the view mode is used
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
    setlocal nomodifiable
    setlocal nolist
    setlocal winfixwidth
    setlocal textwidth=0
    setlocal nospell

    setlocal nonumber

    setlocal nofoldenable
    setlocal foldcolumn=0
    " Reset fold settings in case a plugin set them globally to something
    " expensive. Apparently 'foldexpr' gets executed even if 'foldenable' is
    " off, and then for every appended line (like with :put).
    setlocal foldmethod&
    setlocal foldexpr&

    call s:debug('InitWindow finished')
endfunction

" s:UpdateWindow() {{{2
function! s:UpdateWindow(content) abort
  let srclibwinnr = bufwinnr(s:BufferName)
  if srclibwinnr == -1
    call s:debug("UpdateWindow finished, window doesn't exist")
    return
  endif

  call s:GotoWin(srclibwinnr)

  set modifiable
  normal! ggdG
  let p = s:path . '/sourcegraph.py'
  execute ':pyfile ' . p
  set nomodifiable

  execute 'wincmd p'
endfunction

" s:SrcClose() {{{2
function! s:SrcClose() abort
    call s:debug('SrcClose called')

    let window = bufwinnr(s:BufferName)
    if window == -1
        call s:debug('Sourcelib window not found')
        return
    endif

    exe window . 'close'

    call s:debug('SrcClose finished')
endfunction

" Helper functions {{{1
" s:GotoWin() {{{2
function! s:GotoWin(winnr, ...) abort
  let cmd = type(a:winnr) == type(0) ? a:winnr . 'wincmd w'
        \ : 'wincmd ' . a:winnr
  let noauto = a:0 > 0 ? a:1 : 0

  call s:debug("GotoWin(): " . cmd . ", " . noauto)

  if noauto
    noautocmd execute cmd
  else
    execute cmd
  endif
endfunction

" s:debug() {{{2
if has('reltime')
  function! s:gettime() abort
    let time = split(reltimestr(reltime()), '\.')
    return strftime('%Y-%m-%d %H:%M:%S.', time[0]) . time[1]
  endfunction
else
  function! s:gettime() abort
    return strftime('%Y-%m-%d %H:%M:%S')
  endfunction
endif
function! s:debug(msg) abort
  if s:debug
    execute 'redir >> ' . s:debug_file
    silent echon s:gettime() . ': ' . a:msg . "\n"
    redir END
  endif
endfunction
