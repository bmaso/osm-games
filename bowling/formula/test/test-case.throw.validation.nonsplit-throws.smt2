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
    (not (split t))
    (or
      (not (and
        (>= (points t) 0)
        (<= (points t) 10)))))
)) :named test-case.throw.validation.nonsplit-throws))

(check-sat)