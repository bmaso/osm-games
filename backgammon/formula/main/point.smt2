#include "color.smt2"

#ifndef BACKGAMMON_DOMAIN_POINT
#define BACKGAMMON_DOMAIN_POINT

; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; A backgammon point contains 1 or more checkers of either `Red` or `Black` color. The `Neutral` color is assigned when a `Point` has
;; 0 checkers.

(declare-datatype Point (
  (point
    (color Color)
    (count Int))
))

;;;;
;; Convenience constant `empty-point` represents a point with no checkers on it.
(define-const empty-point Point
  (point
    Neutral          ; color
    0)               ; count
)

;;;;
;; convenience function `point.can-target` indicates whether or not a checker owned by the indicated player can land on the point. The test is
;; whether or not the opposing player owns the point, and if so is the point not a blot?

(define-fun point.can-target ((p Point) (player Color)) Bool
  (ite
    (or
      (= (color p) player)
      (= (color p)  Neutral))
    true
    (< (count p) 2))
)

;;;;
;; convenience function `point.is-blot`: a point is a "blot" if it has exactly one checker

(define-fun point.is-blot ((p Point)) Bool
  (= 1 (count p))
)

;;;;
;; A _valid_ point has these constraints:
;; - it has the color `Neutral` when the count is 0
;; - it has the color `Red` or `Black` (ie _not_ `Neutral`) when the count is > 0
;; - it does not have a negative count value

(declare-fun point.validation (Point) Bool)
(assert (! (forall ((p Point))
  (=
    (and
      (=
        (= (color p) Neutral)
        (= (count p) 0))
      (=>
        (not (= (color p) Neutral))
        (> (count p) 0))
      (>= (count p) 0))
    (point.validation p))
) :named point.validation ))

#endif