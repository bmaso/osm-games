#include "color.smt2"

#ifndef BACKGAMMON_DOMAIN_BAR
#define BACKGAMMON_DOMAIN_BAR

; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; A `Bar` represents the portion of a backgammon board where checkers that have been "hit" rest until they can re-enter the board. As
;; a standalone data value, a `Bar` simply holds a number of `Red` and `Black` pieces.

(declare-datatype Bar (
  (bar
    (red-count Int)
    (black-count Int))
))

;;;;
;; Convenience constant for a `Bar` with no pieces in it

(define-const empty-bar Bar
  (bar
    0         ; red-count
    0)        ; black-count
)

;;;;
;; A bar is valid so long as both the number of `Red` and `Black` pieces is non-negative.

(declare-fun bar.validation (Bar) Bool)
(assert (! (forall ((b Bar))
  (=
    (and
      (>= (red-count b) 0)
      (>= (black-count b) 0))
    (bar.validation b))
) :named bar.validation ))

#endif
