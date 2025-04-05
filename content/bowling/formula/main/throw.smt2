#ifndef BOWLING_THROW_DOMAIN
#define BOWLING_THROW_DOMAIN

; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; A throw has a count of pins knocked down, called "points", and a some additional flags:
;; - a "foul" flag, indicating the player committed a foul during delivery
;; - a "split" flag, inidicating the pins left standing after the throw are in a certain configuration
;; - an "unused" flag, indicating the throw is not taken; for example, the second throw in a strike frame is unused
;; - an "incomplete" flag, indicating the throw has not occurred yet. In incomplete throw is used as a placeholder
;;   for future throws in frame and game datatypes.
;;;;;;;;;;

(declare-datatype Throw (
  (throw
    (points Int)
    (split Bool)
    (foul Bool)
    (unused Bool)
    (incomplete Bool))
))

;;;;
;; A few convenience throw constants:
;; - `incomplete` to represent any incomplete throw -- note the flag fields are all `false` in an incomplete throw
;; - `strike-throw` to represent any 10-pin throw
;; - `foul-throw` to represent any foul throw
;; - `unused-throw` to represent any unused throw
;; - `invalid-throw` which is used as a placeholding in cases where no valid throw value is available
;;;;

(define-const incomplete-throw Throw
  (throw 0 false false false true))

(define-const strike-throw Throw
  (throw 10 false false false false))

(define-const foul-throw Throw
  (throw 0 false true false false))

(define-const unused-throw Throw
  (throw 0 false false true false))

;;;;
;; Validation rules for throws.
;; - the incomplete-throw is valid
;; - the unused-throw is valid
;; - the foul-throw is valid
;; - the strike-throw is valid
;; - a split throw with 3-8 points is valid (the foul, unused, and incomplete flags must be false)
;; - a non-split throw wih 0-10 points is valid (the foul, unused, and incomplete flags must be false)
;;
;; All other throws are invalid
;;;;

(declare-fun throw.validation.is-standard-throw (Throw) Bool)
(assert (! (forall ((t Throw))
  (=
    (or
      (= t incomplete-throw)
      (= t strike-throw)
      (= t foul-throw)
      (= t unused-throw))
    (throw.validation.is-standard-throw t))
) :named throw.validation.is-standard-throw))

(declare-fun throw.validation.is-valid-split-throw (Throw) Bool)
(assert (! (forall ((t Throw))
  (=
    (and
      (split t)
      (not (foul t))
      (not (unused t))
      (not (incomplete t))
      (>= (points t) 3)
      (<= (points t) 8))
    (throw.validation.is-valid-split-throw t))
) :named throw.validation.is-valid-split-throw))

(declare-fun throw.validation.is-valid-nonsplit-throw (Throw) Bool)
(assert (! (forall ((t Throw))
  (=
    (and
      (not (split t))
      (not (foul t))
      (not (unused t))
      (not (incomplete t))
      (>= (points t) 0)
      (<= (points t) 10))
    (throw.validation.is-valid-nonsplit-throw t))
) :named throw.validation.is-valid-nonsplit-throw))

(define-fun throw.validation ((t Throw)) Bool
  (or
    (throw.validation.is-standard-throw t)
    (throw.validation.is-valid-split-throw t)
    (throw.validation.is-valid-nonsplit-throw t))
)

#endif