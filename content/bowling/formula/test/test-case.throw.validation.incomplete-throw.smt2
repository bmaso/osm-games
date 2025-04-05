#include "throw.smt2"
;;|| __FILE__ || __LINE__ ||

;;
;; An incomplete throw with any of the flags `{foul, unused, split}` set, or with a non-zero point value, is
;; not valid in all cases
;;
(assert (! (not (exists ((t Throw))
  (and
    (throw.validation t)
    (incomplete t)
    (or
      (foul t)
      (unused t)
      (split t)
      (not (= 0 (points t)))))
)) :named test-case.throw.validation.incomplete-throw))

(check-sat)
