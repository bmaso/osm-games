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
;; A _valid_ point has these constraints:
;; - Has the color `Neutral` when the count is 0
;; - Has the color `Red` or `Black` (ie _not_ `Neutral`) when the count is > 0
;; - Does not have a negative count value

(declare-fun point.validation (Point) Bool)
(assert (! (forall ((p Point))
  (=
    (and
      (=
        (= (color p) Neutral)
        (= (count p) 0))
      (>= (count p) 0))
    (point.validation p))
) :named point.validation ))

#endif