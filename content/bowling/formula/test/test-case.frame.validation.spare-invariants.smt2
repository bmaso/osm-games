#include "frame.smt2"
;; || __FILE__ || __LINE__ ||

;;
;; Prove that:
;; * There are no valid spare frames where the strike flag is set, the first throw is incomplete, the first throw is
;;   a strike-throw, the second throw is incomplete, the sum of the first two throws is not 10, the first bonus throw
;;   is unused, or that the second bonus throw is not unused
;;

(assert (! (not (exists ((f Frame))
  (and
    (frame.validation f)
    (spare f)
    (or
      (strike f)
      (= strike-throw (throw_1 f))
      (incomplete (throw_1 f))
      (incomplete (throw_2 f))
      (not (= 10 (+ (points (throw_1 f)) (points (throw_2 f)))))
      (= unused-throw (bonus_1 f))
      (not (= unused-throw (bonus_2 f)))))
)) :named test-case.frame.validation.spare-invariants ))

(check-sat)
