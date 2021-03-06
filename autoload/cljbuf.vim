let s:save_cpo = &cpo
set cpo&vim

let g:cljbuf#max_line_length = get(g:, 'cljbuf#max_line_length', 512)

let s:last_sexp = ''

function! cljbuf#eval_and_echo(sexp) abort
  try
    let result = fireplace#eval(a:sexp)
    echo '=> ' . result
  catch /.*/
    echo '!> ' . v:exception
  endtry
endfunction

""" Evaluate `a:sexp` and print to clj-buffer.
function! cljbuf#eval(sexp) abort
  redir => s
  silent execute printf(':CljbufEvalAndEcho %s', a:sexp)
  redir END

  let s:last_sexp = a:sexp

  let outputs = []
  for line in split(s, '\r\?\n')
    if line == 'No matching autocommands'
      continue
    endif
    call add(outputs, '; ' . line)
  endfor
  call add(outputs, '')

  call cljbuf#buffer#append([a:sexp])
  call cljbuf#buffer#append(outputs)
endfunction

""" Operator function to evaluate textobject.
function! cljbuf#eval_operation(type) abort
	let reg_save = @@
  try
    silent exe "normal! `[v`]y"
    call cljbuf#eval(@@)
  finally
    let @@ = reg_save
  endtry
endfunction

""" Repeat last evaluation.
function! cljbuf#repeat_last_eval() abort
  call cljbuf#eval(s:last_sexp)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
