#include "bar.smt2"

;;;;;;;;;;
;; Proves that:
;; - All valid `Bar` values have a non-negative `Red` count
;; - All valid `Bar` values have a nono-negative `Black` count

(assert (! (not (exists ((b Bar))
  (and
    (bar.validation b)
    (< (red-count b) 0))
)) :named test-case.bar.validation.red-count-not-negative))

(assert (! (not (exists ((b Bar))
  (and
    (bar.validation b)
    (< (black-count b) 0))
)) :named test-case.bar.validation.black-count-not-negative))

(check-sat)
