#ifndef BOWLING_THROW_DOMAIN
#define BOWLING_THROW_DOMAIN

; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; A throw has a BitVec of pins knocked down, `pins`, and a some additional flags:
;; - a "foul" flag, indicating the player committed a foul during delivery
;; - an "unused" flag, indicating the throw is not taken; for example, the second throw in a strike frame is unused
;; - an "incomplete" flag, indicating the throw has not occurred yet. In incomplete throw is used as a placeholder
;;   for future throws in frame and game datatypes.
;;
;; The `pins` value is interpreted this way: a `1` value means the associated pin was knocked by by this throw.
;; A strike is `#b1111111111`. A throw that knocks down the 1 and 10 pins, regardless of whether the other pins
;; were already up or down when the throw was made, will have the value `#b1000000001`.
;;;;;;;;;;

(declare-datatype Throw (
  (throw
    (pins (_ BitVec 10))
    (foul Bool)
    (unused Bool)
    (incomplete Bool))))

;;;;
;; A few convenience throw constants:
;; - `foul-throw` to represent any foul throw
;; - `unused-throw` to represent any unused throw
;; - `incomplete-throw` to represent any incomplete throw -- note the flag fields are all `false` in an incomplete throw
;;
;; The `pins` value of incomplete, foul, and unused throws are all `#b0000000000`, indicating no pins knocked down
;;;;

(define-const foul-throw Throw
  (throw #b0000000000 true false false))

(define-const unused-throw Throw
  (throw #b0000000000 false true false))

(define-const incomplete-throw Throw
  (throw #b0000000000 false false true))

(define-const strike-throw Throw
  (throw #b1111111111 false false false))

;;;;
;; Split test function. Checks to see if the pins match any of the known split configurations.
;;
;; Note: sometimes you'll hear a 5-6 or 6-7 configuration described as a "baby split". Neither of these
;; are "splits" by the USBC or IBF rules.
;;;;

(define-fun is-split-pins ((pins (_ BitVec 10))) Bool
  (or
    (= #b0100001000 pins)   ;; "2-7" split
    (= #b0010000001 pins)   ;; "3-10" split
    (= #b0000001001 pins)   ;; "7-10" split
    (= #b0100000001 pins)   ;; "2-10" split
    (= #b0010001000 pins)   ;; "3-7" split
    (= #b0001010000 pins)   ;; "4-6" split
    (= #b0001001001 pins)   ;; "4-7-10" split
    (= #b0101000001 pins)   ;; "2-4-10" split
    (= #b0100001001 pins)   ;; "2-7-10" split
    (= #b0010011000 pins)   ;; "3-6-7" split
    (= #b0010010001 pins)   ;; "3-6-10" split
    (= #b0101001000 pins)   ;; "2-4-7" split
    (= #b0010010011 pins)   ;; "3-6-9-10" split
    (= #b0001011001 pins)   ;; "4-6-7-10" split
    (= #b0001011000 pins)   ;; "4-6-7" split
    (= #b0001010001 pins))) ;; "4-6-10" split

;;;;
;; Validation rules for throws.
;; - the unused-throw is valid
;; - the foul-throw is valid
;; - the incomplete-throw is valid
;; - Any other throw where these three flags are unset
;;;;

(define-fun throw.valid ((t Throw)) Bool
  (or
    (= foul-throw t)
    (= unused-throw t)
    (= incomplete-throw t)
    (and
      (not (foul t))
      (not (unused t))
      (not (incomplete t)))))

;;;;
;; The point value of a throw is the total number of pins knocked down. A bitvector _population_ value, also known as the
;; _Hamming wieght_, is the number of bits with a 1 value. This would be the number of pins knocked down in a `Throw`.
;; Surprisingly, the `smtlib2` standard library doesn't have a native operator for bitvector population, so we have
;; to make our own using bit extraction and numeric convertion from a bitvector to integer.
;;
;; Notes:
;; - `((_ zero_extend N) bitvector)` returns a new bitvector with N more 0-valued bits concatted to the left (msb) side
;;   of input bitvector
;; - `((_ extract x y) bitvector)` returns a new bitvector of length (y - x + 1) with values taken from the x through y bits
;;   (inclusive) of input bitvector
;;;;

(define-fun throw.points ((t Throw)) Int
  (bv2nat
    (bvadd
      ((_ zero_extend 3) ((_ extract 0 0) (pins t)))
      ((_ zero_extend 3) ((_ extract 1 1) (pins t)))
      ((_ zero_extend 3) ((_ extract 2 2) (pins t)))
      ((_ zero_extend 3) ((_ extract 3 3) (pins t)))
      ((_ zero_extend 3) ((_ extract 4 4) (pins t)))
      ((_ zero_extend 3) ((_ extract 5 5) (pins t)))
      ((_ zero_extend 3) ((_ extract 6 6) (pins t)))
      ((_ zero_extend 3) ((_ extract 7 7) (pins t)))
      ((_ zero_extend 3) ((_ extract 8 8) (pins t)))
      ((_ zero_extend 3) ((_ extract 9 9) (pins t))))))

#endif