#include "point.smt2"

;;;;;;;;;;
;; Proves that:
;; - All valid points have non-negative count
;; - All valid points that are not neutral have non-zero count
;; - All neutral points have 0 count

(assert (! (not (exists ((p Point))
  (and
    (point.validation p)
    (< (count p) 0))
)) :named test-case.point.validation.no-points-with-negative-count ))

(assert (! (not (exists ((p Point))
  (and
    (point.validation p)
    (= Neutral (color p))
    (not (= 0 (count p))))
)) :named test-case.point.validation.neutral-points-have-zero-count ))

(check-sat)
