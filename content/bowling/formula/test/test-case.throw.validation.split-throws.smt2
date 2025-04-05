#include "throw.smt2"
;;|| __FILE__ || __LINE__ ||

;;
;; A split throw with any of the flags `{unused, foul, incomplete}` set, or with a point value outside the
;; range 3-8 is not valid in all cases
;;

(push 1)

(assert (! (not (exists ((t Throw))
  (and
    (throw.validation t)
    (split t)
    (or
      (unused t)
      (foul t)
      (incomplete t)
      (not (and
        (>= (points t) 3)
        (<= (points t) 8)))))
)) :named test-case.throw.validation.split-throws))

(check-sat)