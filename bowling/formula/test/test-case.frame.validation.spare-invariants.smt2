#include "frame.smt2"
;; || __FILE__ || __LINE__ ||

;;
;; Prove that there are no valid spare frames where:
;; * the first throw is a strike
;; * the first or second throws are incomplete
;; * the sum of the first two throws' points values is not 10
;; * the first bonus throw is unused
;; * the second bonus throw is not unused
;;

(assert (! (not (exists ((f Frame))
  (and
    (frame.valid f)
    (not (= strike-throw (throw_1 f)))
    (= #b1111111111 (bvor (pins (throw_1 f)) (pins (throw_2 f))))
    (or
      (= strike-throw (throw_1 f))
      (incomplete (throw_1 f))
      (incomplete (throw_2 f))
      (not (= 10 (+ (throw.points (throw_1 f)) (throw.points (throw_2 f)))))
      (= unused-throw (bonus_1 f))
      (not (= unused-throw (bonus_2 f)))))
)) :named test-case.frame.validation.spare-invariants ))

(check-sat)
