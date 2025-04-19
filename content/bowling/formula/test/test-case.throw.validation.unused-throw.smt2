#include "throw.smt2"
;;|| __FILE__ || __LINE__ ||

;;;;
;; There are no valid unused throws with any of the flags `{foul, incomplete}` set, or that are "splits", or
;; with any pins knocked down.
;;;;

(assert (! (not (exists ((t Throw))
  (and
    (throw.valid t)
    (unused t)
    (or
      (foul t)
      (incomplete t)
      (is-split-pins (pins t))
      (not (= #b0000000000 (pins t)))))
)) :named test-case.throw.validation.unused-throw))

(check-sat)