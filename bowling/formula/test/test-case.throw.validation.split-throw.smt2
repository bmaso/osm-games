#include "throw.smt2"
;;|| __FILE__ || __LINE__ ||

;;;;
;; There are no split throws with any of the flags `{foul, unused, incomplete}` set.
;;;;

(assert (! (not (exists ((t Throw))
  (and
    (throw.valid t)
    (is-split-pins (pins t))
    (or
      (foul t)
      (unused t)
      (incomplete t)))
)) :named test-case.throw.validation.nonsplit-throws))

(check-sat)