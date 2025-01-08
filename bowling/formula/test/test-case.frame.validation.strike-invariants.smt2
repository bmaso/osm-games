#include "frame.smt2"
;; || __FILE__ || __LINE__ ||

;;
;; Prove that:
;; * There are no valid strike frames where the spare flag is set, the first frame is not a strike,
;;   the second frame is not unused, and either of the bonus frames are unused
;;

(assert (! (not (exists ((f Frame))
  (and
    (frame.validation f)
    (strike f)
    (or
      (spare f)
      (not (= strike-throw (throw_1 f)))
      (not (= unused-throw (throw_2 f)))
      (= unused-throw (bonus_1 f))
      (= unused-throw (bonus_2 f))))
)) :named test-case.frame.validation.strike-invariants ))

(check-sat)
