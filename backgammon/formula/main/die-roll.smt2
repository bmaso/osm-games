#include "color.smt2"

;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; A die roll is comprised of:
;; - a player value indicating which player made the roll; the `Color` type is used to represent this.
;; - an integer die value

(declare-datatype DieRoll (
  (die-roll
    (player Color)
    (value Int))
))

;;;;
;; A _valid_ roll has these restrictions:
;; - the player must cannot be `Neutral`
;; - the die value must be 1 <= value <= 6

(declare-fun die-roll.validation (DieRoll) Bool)
(assert (! (forall ((d DieRoll))
  (=
    (and
      (not (= Neutral (player d)))
      (>= (value d) 1)
      (<= (value d) 6))
    (die-roll.validation d))
) :named die-roll.validation ))
