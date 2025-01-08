#include "throw.smt2"
;;|| __FILE__ || __LINE__ ||

;;
;; An unused throw with any of the flags `{foul, split, incomplete}` set, or with a non-zero point value, is
;; not valid in all cases
;;

(push 1)

(assert (! (not (exists ((t Throw))
  (and
    (throw.validation t)
    (unused t)
    (or
      (foul t)
      (split t)
      (incomplete t)
      (not (= 0 (points t)))))
)) :named test-case.throw.validation.unused-throw))

(check-sat)