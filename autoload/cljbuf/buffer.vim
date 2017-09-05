let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('cljbuf')
let s:S = s:V.import('Data.String')
let s:BM = s:V.import('Vim.BufferManager')

let g:cljbuf#buffer#name = get(g:, 'cljbuf#buffer#name', 'cljbuf')
let g:cljbuf#buffer#mods = get(g:, 'cljbuf#buffer#mods', '')
let g:cljbuf#buffer#info = {}

function! s:focus_window(buffer_no) abort
  execute printf(':%dwincmd w', a:buffer_no)
endfunction

function! s:reeval() abort
  " FIXME: in-ns
  let line = getline('.')
  if ! s:S.starts_with(line, ';')
    call cljbuf#eval(line)
  endif
endfunction

function! s:apply_buffer_settings() abort
  " FIXME: autogroup
  setlocal filetype=clojure
  setlocal nobuflisted
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal nomodifiable

  nnoremap <silent> <buffer> q :<C-u>q<CR>
  nnoremap <silent> <buffer> <CR> :call <SID>reeval()<CR>
endfunction

""" Move focus to clj-buffer.
function! cljbuf#buffer#focus() abort
  if has_key(g:cljbuf#buffer#info, 'bufnr')
    call s:focus_window(bufwinnr(g:cljbuf#buffer#info['bufnr']))
  endif
endfunction

""" Open clj-buffer.
function! cljbuf#buffer#open() abort
  if !has_key(g:cljbuf#buffer#info, 'bufnr') || bufwinnr(g:cljbuf#buffer#info['bufnr']) < 0
    let bm = s:BM.new()
    let current_window = bufwinnr(bufnr('%'))

    let g:cljbuf#buffer#info = bm.open(g:cljbuf#buffer#name, {
        \ 'mods' : g:cljbuf#buffer#mods
        \ })
    call s:apply_buffer_settings()
    call s:focus_window(bufwinnr(current_window))
  endif
endfunction

""" Append `a:lines` (array of string) to clj-buf.
function! cljbuf#buffer#append(lines) abort
  call cljbuf#buffer#open()

  let current_window = bufwinnr(bufnr('%'))
  call s:focus_window(bufwinnr(g:cljbuf#buffer#info['bufnr']))
  setlocal modifiable

  for line in a:lines
    if g:cljbuf#max_line_length > 0 && strlen(line) > g:cljbuf#max_line_length
      let line = strpart(line, 0, g:cljbuf#max_line_length) . ' ...'
    endif
    call append(line('$'), line)
  endfor
  call cursor(line('$'), 0) " move cursor to bottom

  setlocal nomodifiable
  call s:focus_window(bufwinnr(current_window))
endfunction

""" Clear clj-buffer.
function! cljbuf#buffer#clear() abort
  call cljbuf#buffer#open()

  let current_window = bufwinnr(bufnr('%'))
  call s:focus_window(bufwinnr(g:cljbuf#buffer#info['bufnr']))
  setlocal modifiable
  silent normal! ggdG
  setlocal nomodifiable
  call s:focus_window(bufwinnr(current_window))
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
