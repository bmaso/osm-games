#include "throw.smt2"
;;|| __FILE__ || __LINE__ ||

;;
;; A foul throw with any of the flags `{unused, split, incomplete}` set, or with a non-zero point value, is
;; not valid in all cases
;;

(push 1)

(assert (! (not (exists ((t Throw))
  (and
    (throw.validation t)
    (foul t)
    (or
      (unused t)
      (split t)
      (incomplete t)
      (not (= 0 (points t)))))
)) :named test-case.throw.validation.foul-throw))

(check-sat)