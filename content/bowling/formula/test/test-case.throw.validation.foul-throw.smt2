#include "throw.smt2"
;;|| __FILE__ || __LINE__ ||

;;;;
;; There are no valid foul throws with any of the flags `{unused, incomplete}` set, or that are "splits", or
;; with any pins knocked down.
;;;;

(assert (! (not (exists ((t Throw))
  (and
    (throw.valid t)
    (foul t)
    (or
      (unused t)
      (incomplete t)
      (is-split-pins (pins t))
      (not (= #b0000000000 (pins t)))))
)) :named test-case.throw.valid.foul-throw))

(check-sat)