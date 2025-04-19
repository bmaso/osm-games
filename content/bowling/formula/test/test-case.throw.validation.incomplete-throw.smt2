#include "throw.smt2"
;;|| __FILE__ || __LINE__ ||

;;;;
;; There are no valid incomplete throws with any of the flags `{unused, foul}` set, or that are "splits", or
;; with any pins knocked down.
;;;;

(assert (! (not (exists ((t Throw))
  (and
    (throw.valid t)
    (incomplete t)
    (or
      (foul t)
      (unused t)
      (is-split-pins (pins t))
      (not (= #b0000000000 (pins t)))))
)) :named test-case.throw.validation.incomplete-throw))

(check-sat)
