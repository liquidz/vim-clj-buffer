if exists('g:loaded_clj_buffer')
  finish
endif
let g:loaded_clj_buffer = 1

let s:save_cpo = &cpo
set cpo&vim

"private
command! -nargs=1 CljbufEvalAndEcho call cljbuf#eval_and_echo(<q-args>)

command!          CljbufClear       call cljbuf#buffer#clear()
command! -nargs=1 CljbufEval        call cljbuf#eval(<q-args>)
command!          CljbufOpen        call cljbuf#buffer#open()
command!          CljbufRepeatLast  call cljbuf#repeat_last_eval()
command!          CljbufTestAll     call cljbuf#test_all()
command!          CljbufTestFile    call cljbuf#test_file()
command!          CljbufFocusBuffer call cljbuf#buffer#focus()

nnoremap <silent> <Plug>(cljbuf_clear)        :<C-u>CljbufClear<CR>
nnoremap <silent> <Plug>(cljbuf_eval)         :<C-u>set opfunc=cljbuf#eval_operation<CR>g@
nnoremap <silent> <Plug>(cljbuf_repeat_last)  :<C-u>CljbufRepeatLast<CR>
nnoremap <silent> <Plug>(cljbuf_test_all)     :<C-u>CljbufTestAll<CR>
nnoremap <silent> <Plug>(cljbuf_test_file)    :<C-u>CljbufTestFile<CR>
nnoremap <silent> <Plug>(cljbuf_focus_buffer) :<C-u>CljbufFocusBuffer<CR>

let &cpo = s:save_cpo
unlet s:save_cpo

