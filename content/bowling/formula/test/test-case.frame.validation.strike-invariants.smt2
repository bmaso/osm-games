#include "frame.smt2"
;; || __FILE__ || __LINE__ ||

;;
;; Prove that there are no valid strike frames where:
;; * the first frame is not a strike
;; * the second frame is not unused
;; * and either of the bonus frames are unused
;;

(assert (! (not (exists ((f Frame))
  (and
    (frame.valid f)
    (= #b1111111111 (pins (throw_1 f)))
    (or
      (not (= strike-throw (throw_1 f)))
      (not (= unused-throw (throw_2 f)))
      (= unused-throw (bonus_1 f))
      (= unused-throw (bonus_2 f))))
)) :named test-case.frame.validation.strike-invariants ))

(check-sat)
