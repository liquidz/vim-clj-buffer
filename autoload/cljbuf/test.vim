let s:save_cpo = &cpo
set cpo&vim

let g:cljbuf#test#runner = get(g:, 'cljbuf#test#runner', 'clojure.test')
let g:cljbuf#test#eftest_reporter = get(g:, 'cljbuf#test#eftest_reporter', 'eftest.report.pretty/report')

function! s:require_eftest() abort
  call fireplace#eval("(require 'eftest.runner 'eftest.report.pretty)")
endfunction

function! s:get_run_test_sexp(namespace) abort
  let r = g:cljbuf#test#runner
  if r ==# 'eftest.runner'
    call s:require_eftest()
    return printf("(%s/run-tests (%s/find-tests '%s) {:report %s})",
        \ r, r, a:namespace, g:cljbuf#test#eftest_reporter)
  else
    " clojure.test
    return printf("(%s/run-tests '%s)", r, a:namespace)
  endif
endfunction

function! s:get_run_all_test_sexp(project) abort
  let r = g:cljbuf#test#runner
  if r ==# 'eftest.runner'
    call s:require_eftest()
    return printf('(%s/run-tests (%s/find-tests "test") {:report %s})',
        \ r, r, g:cljbuf#test#eftest_reporter)
  else
    " clojure.test
    return printf('(%s/run-all-tests #"%s.*")', r, project)
  endif
endfunction

""" Run tests for a current namespace.
function! cljbuf#test#file() abort
	let ns = fireplace#ns()
  if match(ns, 'test$') ==# -1
    let test_ns = ns . '-test'
  else
    let test_ns = ns
    let ns = substitute(ns, '-test', '', '')
  endif

  call fireplace#eval(printf("(require '%s :reload)", ns))
  call fireplace#eval(printf("(require '%s :reload)", test_ns))
  "call cljbuf#eval(printf("(clojure.test/run-tests '%s)", test_ns))
  call cljbuf#eval(s:get_run_test_sexp(test_ns))
endfunction

""" Run all tests for current project's namespaces.
function! cljbuf#test#all() abort
	let ns = fireplace#ns()
  let prefix = split(ns, '\.')[0]
  call fireplace#eval(printf("(require '%s :reload)", ns))
  "call cljbuf#eval(printf('(clojure.test/run-all-tests #"%s.*")', prefix))
  call cljbuf#eval(s:get_run_all_test_sexp(prefix))
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
